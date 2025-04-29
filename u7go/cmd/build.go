package cmd

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"time" // Needed for spinner

	"github.com/briandowns/spinner" // Import spinner
	"github.com/fatih/color"
	"github.com/spf13/cobra"
	"github.com/unoften/U7Revisited/u7go/internal/utils"
)

// buildCmd represents the build command
var buildCmd = &cobra.Command{
	Use:   "build",
	Short: "Build the U7Revisited project (debug or release).",
	Long:  `Builds the C++ source code using Meson and Ninja. Configures the build directory if it doesn't exist.`,
	Run: func(cmd *cobra.Command, args []string) {
		color.Cyan("--- Build Task (%s) ---", buildType)

		// Validate buildType (already checked in clean, but good practice)
		if buildType != "debug" && buildType != "release" {
			color.Red("Invalid build type specified: %s. Use 'debug' or 'release'.", buildType)
			os.Exit(1)
		}

		// 1. Check Core Dependencies (Meson/Ninja)
		// Assuming Go is present since this app is running
		deps := []string{"meson", "ninja"}
		if err := utils.CheckDependencies(deps...); err != nil {
			color.Red("Dependency check failed: %v", err)
			os.Exit(1)
		}
		color.Green("  [OK] Found Meson and Ninja.")

		// 2. Find Project Root
		projectRoot, err := utils.ProjectRoot()
		if err != nil {
			color.Red("Error finding project root: %v", err)
			os.Exit(1)
		}

		// 3. Determine build path
		buildDirName := "build-" + buildType
		buildDirPath := filepath.Join(projectRoot, buildDirName)

		// 4. Configure Meson if build directory doesn't exist
		if _, err := os.Stat(buildDirPath); os.IsNotExist(err) {
			color.Yellow("Build directory %s not found. Running Meson setup...", buildDirName)
			mesonSetupCmd := exec.Command("meson", "setup", buildDirName, "--buildtype="+buildType)
			mesonSetupCmd.Dir = projectRoot // Run from project root
			output, err := mesonSetupCmd.CombinedOutput()
			if err != nil {
				color.Red("Meson setup failed:\n%s", string(output))
				os.Exit(1)
			}
			color.Green("Meson setup complete for %s.", buildDirName)
		} else {
			color.Green("Build directory %s already exists.", buildDirName)
			// TODO: Add logic for --reconfigure flag later if needed
		}

		// 5. Compile with Meson
		color.Cyan("Running Meson compile in %s...", buildDirName)

		// --- Spinner ---
		s := spinner.New(spinner.CharSets[14], 100*time.Millisecond) // Use a nice spinner
		s.Suffix = " Compiling..."
		s.Color("blue") // Set spinner color
		s.Start()
		// --- End Spinner ---

		mesonCompileCmd := exec.Command("meson", "compile", "-C", buildDirName)
		mesonCompileCmd.Dir = projectRoot // Run from project root

		// Capture combined output (stdout & stderr)
		compileOutputBytes, compileErr := mesonCompileCmd.CombinedOutput()
		compileOutput := string(compileOutputBytes)

		s.Stop() // Stop spinner regardless of success/error

		// --- Debug: Print raw output ---
		// color.Cyan("[DEBUG] Raw compile output (first 500 chars):\n%s\n--------------------", compileOutput[:min(500, len(compileOutput))])

		// --- Debug: Print flag value ---
		// color.Magenta("[DEBUG] warnings flag value: %t", warnings)

		// Process output for errors/warnings
		errorCount := 0
		warningCount := 0
		// Initialize with capacity
		filteredOutput := make([]string, 0, 100)
		outputScanner := bufio.NewScanner(strings.NewReader(compileOutput))

		// Basic regex for typical compiler warnings/errors (adjust as needed)
		// This is a simplified example; robust parsing can be complex.
		warningRegex := regexp.MustCompile(`(?i)(warning|warn):`)
		errorRegex := regexp.MustCompile(`(?i)(error|err):`)

		for outputScanner.Scan() {
			line := outputScanner.Text()
			// color.HiBlack("[DEBUG] Scanning line: %s", line) // Debug print inside loop
			isError := errorRegex.MatchString(line)
			isWarning := warningRegex.MatchString(line)

			if isError {
				errorCount++
				// Append raw line, color later
				filteredOutput = append(filteredOutput, line)
			} else if isWarning {
				//color.Cyan("[DEBUG] Regex matched potential warning line: %s", line) // Debug print
				warningCount++
				if warnings { // Only add warnings if flag is set
					color.HiMagenta("[DEBUG] INSIDE 'if warnings' block - Appending RAW line!")
					color.Yellow("[DEBUG] Line content JUST BEFORE append: '%s'", line)
					filteredOutput = append(filteredOutput, line)
					// Add this debug line
					// color.Cyan("[DEBUG] Size of filteredOutput IMMEDIATELY AFTER append: %d", len(filteredOutput))
				}
			} else {
				// Optionally include non-error/warning lines if needed
				// filteredOutput = append(filteredOutput, line)
			}
		}

		// --- Debug: Print filtered list size ---
		// color.Magenta("[DEBUG] Size of filteredOutput: %d", len(filteredOutput))

		// Print filtered summary
		color.Cyan("\n--- Build Summary ---")
		if compileErr != nil {
			// If meson compile command itself failed, print the raw output snippet
			color.Red("Meson compile command failed (Exit Code: %d)!", mesonCompileCmd.ProcessState.ExitCode())
			// Print last few lines of raw output for context
			rawLines := strings.Split(strings.TrimSpace(compileOutput), "\n")
			start := len(rawLines) - 10
			if start < 0 {
				start = 0
			}
			color.HiBlack("Last ~10 lines of output:\n%s", strings.Join(rawLines[start:], "\n"))

		}

		// Print filtered errors/warnings
		if len(filteredOutput) > 0 {
			var coloredOutputLines []string
			for _, l := range filteredOutput {
				if errorRegex.MatchString(l) {
					coloredOutputLines = append(coloredOutputLines, color.RedString(l))
				} else if warningRegex.MatchString(l) {
					coloredOutputLines = append(coloredOutputLines, color.YellowString(l))
				} else {
					coloredOutputLines = append(coloredOutputLines, l)
				}
			}
			fmt.Println(strings.Join(coloredOutputLines, "\n"))
		} else if compileErr == nil {
			// Remove this line - the final status block below handles this correctly
			color.Green("Build complete.")
		}

		// Final status
		if errorCount > 0 {
			color.Red("\nBuild FAILED with %d error(s).", errorCount)
			if warningCount > 0 {
				color.Yellow("Additionally, %d warning(s) were reported.", warningCount)
			}
			os.Exit(1)
		} else if warningCount > 0 && warnings {
			color.Green("\nBuild completed successfully with %d warning(s) reported.", warningCount)
		} else if warningCount > 0 && !warnings {
			color.Yellow("\nBuild completed successfully, but %d warning(s) were reported (use --warnings to see them).", warningCount)
		} else if errorCount == 0 && compileErr == nil {
			// This condition might be slightly redundant now, but safe to keep
			// Let's check specifically for "no work to do"
			if strings.Contains(compileOutput, "ninja: no work to do.") {
				color.Green("Project is already up-to-date. Nothing to build.")
				color.Yellow("(Use 'u7 clean build ...' to force a rebuild if needed)")
			}
		} else {
			// Fallback/unexpected case - should not happen if logic is correct
			color.HiBlack("Build finished with unexpected state (Errors: %d, Warnings: %d, Compile Err: %v)", errorCount, warningCount, compileErr)
		}

	},
}

func init() {
	// This command uses the buildType and warnings flags defined in rootCmd
}

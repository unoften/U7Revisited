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

		// Process output for errors/warnings
		errorCount := 0
		warningCount := 0
		var filteredOutput []string
		outputScanner := bufio.NewScanner(strings.NewReader(compileOutput))

		// Basic regex for typical compiler warnings/errors (adjust as needed)
		// This is a simplified example; robust parsing can be complex.
		warningRegex := regexp.MustCompile(`(?i)(warning|warn):`)
		errorRegex := regexp.MustCompile(`(?i)(error|err):`)

		for outputScanner.Scan() {
			line := outputScanner.Text()
			isError := errorRegex.MatchString(line)
			isWarning := warningRegex.MatchString(line)

			if isError {
				errorCount++
				filteredOutput = append(filteredOutput, color.RedString(line)) // Color errors red
			} else if isWarning {
				warningCount++
				if warnings { // Only add warnings if flag is set
					filteredOutput = append(filteredOutput, color.YellowString(line)) // Color warnings yellow
				}
			} else {
				// Optionally include non-error/warning lines if needed
				// filteredOutput = append(filteredOutput, line)
			}
		}

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
			fmt.Println(strings.Join(filteredOutput, "\n"))
		} else if compileErr == nil {
			color.Green("Build completed with no errors or warnings reported.")
		}

		// Final status
		if errorCount > 0 {
			color.Red("\nBuild FAILED with %d error(s).", errorCount)
			if warningCount > 0 {
				color.Yellow("Additionally, %d warning(s) were reported.", warningCount)
			}
			os.Exit(1)
		} else if warningCount > 0 && !warnings {
			color.Yellow("\nBuild completed successfully, but %d warning(s) were reported (use --warnings to see them).", warningCount)
		} else if warningCount > 0 && warnings {
			color.Green("\nBuild completed successfully with %d warning(s).", warningCount)
		} else {
			// Success message printed above if no errors/warnings
		}

	},
}

func init() {
	// This command uses the buildType and warnings flags defined in rootCmd
}

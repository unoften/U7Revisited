package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"

	"github.com/fatih/color"
	"github.com/spf13/cobra"
	"github.com/unoften/U7Revisited/u7go/internal/utils"
)

// healthcheckCmd represents the healthcheck command
var healthcheckCmd = &cobra.Command{
	Use:   "healthcheck",
	Short: "Run the asset loading health check.",
	Long: `Performs essential asset loading checks without launching the full game.
This command implicitly uses the 'debug' build type and runs verbosely.`,
	Run: func(cmd *cobra.Command, args []string) {
		// Force build type to debug for healthcheck
		forcedBuildType := "debug"
		color.Cyan("--- Health Check Task (Forcing Build Type: %s) ---", forcedBuildType)

		// 1. Find Project Root
		projectRoot, err := utils.ProjectRoot()
		if err != nil {
			color.Red("Error finding project root: %v", err)
			os.Exit(1)
		}

		// 2. Determine Source and Target Executable Paths (using forcedBuildType)
		buildDirName := "build-" + forcedBuildType
		var srcExeName string
		if runtime.GOOS == "windows" {
			srcExeName = "U7Revisited_" + forcedBuildType + ".exe"
		} else {
			srcExeName = "U7Revisited_" + forcedBuildType
		}
		// Assuming executable is directly in build-xxx/ for now
		srcExePath := filepath.Join(projectRoot, buildDirName, srcExeName)
		color.Yellow("Looking for source executable at: %s", srcExePath)

		redistDir := filepath.Join(projectRoot, "Redist")
		targetExePath := filepath.Join(redistDir, srcExeName)

		// 3. Check if Source Executable Exists (Build Check)
		if _, err := os.Stat(srcExePath); os.IsNotExist(err) {
			color.Red("Debug executable not found: %s", srcExePath)
			// Note: Healthcheck often requires a build first. Prompt user.
			color.Yellow("Please build the debug version first using: u7 build --buildtype=debug")
			// Alternatively, we could trigger the build logic here. For now, require manual build.
			// buildCmd.Run(cmd, []string{}) // Example if we wanted to run build first
			os.Exit(1)
		}
		color.Green("  [OK] Found debug executable.")

		// 4. Ensure Redist Directory Exists
		if err := os.MkdirAll(redistDir, 0755); err != nil {
			color.Red("Error creating Redist directory %s: %v", redistDir, err)
			os.Exit(1)
		}

		// 5. Copy Executable to Redist
		color.Cyan("Copying %s to %s...", srcExeName, redistDir)
		err = utils.CopyFile(srcExePath, targetExePath)
		if err != nil {
			color.Red("Error copying executable: %v", err)
			os.Exit(1)
		}

		// Set permissions
		if runtime.GOOS != "windows" {
			if err := os.Chmod(targetExePath, 0755); err != nil {
				color.Yellow("Warning: Could not set executable permission on %s: %v", targetExePath, err)
			}
		}
		color.Green("  [OK] Executable copied to Redist directory.")

		// 6. Execute the Health Check
		color.Cyan("\n--- Running Health Check ---")
		// Prepare arguments: --healthcheck and potentially --verbose
		gameArgs := []string{"--healthcheck", "--verbose"} // Force verbose for health check
		fmt.Printf("Executable: %s\n", targetExePath)
		fmt.Printf("Arguments: %v\n", gameArgs)
		fmt.Printf("Working Directory: %s\n\n", redistDir)

		gameCmd := exec.Command(targetExePath, gameArgs...)
		gameCmd.Dir = redistDir // Set the working directory
		gameCmd.Stdout = os.Stdout
		gameCmd.Stderr = os.Stderr
		gameCmd.Stdin = os.Stdin

		// Run the health check
		err = gameCmd.Run()

		// Check the exit code (Health check passes with code 0, fails otherwise)
		if err != nil {
			if exitErr, ok := err.(*exec.ExitError); ok {
				color.Red("\n--- Health Check FAILED (Code: %d) ---", exitErr.ExitCode())
				os.Exit(exitErr.ExitCode())
			} else {
				color.Red("\n--- Error Running Health Check ---")
				color.Red("Failed to run %s: %v", targetExePath, err)
				os.Exit(1)
			}
		} else {
			// The actual success/warning details are printed by the C++ app itself
			color.Green("\n--- Health Check Command Finished (Code: 0) ---")
			color.Yellow("Review output above for PASS/FAIL status and details.")
		}
	},
}

func init() {
	// Healthcheck doesn't use buildType/warnings flags directly, it forces debug.
}

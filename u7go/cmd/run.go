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

// runCmd represents the run command
var runCmd = &cobra.Command{
	Use:   "run [-- game_args...]",
	Short: "Run the U7Revisited project.",
	Long: `Ensures the project is built, copies the executable to Redist/,
and runs it from there. Arguments after '--' are passed directly to the game executable.`,
	// Allows unknown flags to be passed to the game after '--'
	FParseErrWhitelist: cobra.FParseErrWhitelist{UnknownFlags: true},
	Run: func(cmd *cobra.Command, args []string) {
		color.Cyan("--- Run Task (%s) ---", buildType)

		// Validate buildType
		if buildType != "debug" && buildType != "release" {
			color.Red("Invalid build type specified: %s. Use 'debug' or 'release'.", buildType)
			os.Exit(1)
		}

		// 1. Find Project Root
		projectRoot, err := utils.ProjectRoot()
		if err != nil {
			color.Red("Error finding project root: %v", err)
			os.Exit(1)
		}

		// 2. Determine Source and Target Executable Paths
		buildDirName := "build-" + buildType
		var srcExeName string
		if runtime.GOOS == "windows" {
			srcExeName = "U7Revisited_" + buildType + ".exe"
		} else {
			srcExeName = "U7Revisited_" + buildType
		}
		srcExePath := filepath.Join(projectRoot, buildDirName, srcExeName)

		// --- Important: Meson places executable inside build-xxx/install_prefix/bin for install targets ---
		// Let's adjust the source path assuming no 'install' step for now, just direct build output.
		// If using 'meson install', this path needs updating.
		// For now, assume it's directly in build-xxx/
		color.Yellow("Looking for source executable at: %s", srcExePath) // Debug output

		// Redist directory and target executable path
		redistDir := filepath.Join(projectRoot, "Redist")
		targetExePath := filepath.Join(redistDir, srcExeName)

		// 3. Check if Source Executable Exists (Build Check)
		if _, err := os.Stat(srcExePath); os.IsNotExist(err) {
			color.Red("Source executable not found: %s", srcExePath)
			color.Yellow("Please build the project first using: u7 build --buildtype=%s", buildType)
			os.Exit(1)
		}
		color.Green("  [OK] Found source executable.")

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
		// Ensure the copied file is executable (especially on Linux/macOS)
		if runtime.GOOS != "windows" {
			if err := os.Chmod(targetExePath, 0755); err != nil {
				color.Red("Error setting executable permission on %s: %v", targetExePath, err)
				// Don't necessarily exit, maybe it still runs? Or maybe exit... let's warn.
				color.Yellow("Warning: Could not set executable permission. Run may fail.")
			}
		}
		color.Green("  [OK] Executable copied to Redist directory.")

		// 6. Execute the Game
		color.Cyan("\n--- Running Game ---")
		fmt.Printf("Executable: %s\n", targetExePath)
		fmt.Printf("Arguments: %v\n", args)
		fmt.Printf("Working Directory: %s\n\n", redistDir)

		gameCmd := exec.Command(targetExePath, args...)
		gameCmd.Dir = redistDir // Set the working directory
		gameCmd.Stdout = os.Stdout
		gameCmd.Stderr = os.Stderr
		gameCmd.Stdin = os.Stdin // Allow potential game input

		// Run the game
		err = gameCmd.Run()

		// Check the exit code
		if err != nil {
			if exitErr, ok := err.(*exec.ExitError); ok {
				// Command started and exited with non-zero status
				color.Red("\n--- Game Exited with Error (Code: %d) ---", exitErr.ExitCode())
				os.Exit(exitErr.ExitCode()) // Exit u7go with the game's exit code
			} else {
				// Other error (e.g., command not found - unlikely after copy)
				color.Red("\n--- Error Running Game ---")
				color.Red("Failed to run %s: %v", targetExePath, err)
				os.Exit(1)
			}
		} else {
			color.Green("\n--- Game Exited Successfully (Code: 0) ---")
		}
	},
}

func init() {
	// This command uses the buildType flag defined in rootCmd
}

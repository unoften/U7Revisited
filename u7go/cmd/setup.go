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

// setupCmd represents the setup command
var setupCmd = &cobra.Command{
	Use:   "setup",
	Short: "Run the IDE setup script.",
	Long: `Executes the appropriate script (setup_ide.sh or setup_ide.bat)
to generate standard configuration files for common IDEs (VS Code, CLion).`,
	Run: func(cmd *cobra.Command, args []string) {
		color.Cyan("--- IDE Setup Task ---")

		// 1. Find Project Root
		projectRoot, err := utils.ProjectRoot()
		if err != nil {
			color.Red("Error finding project root: %v", err)
			os.Exit(1)
		}

		// 2. Determine script path and command
		scriptsDir := filepath.Join(projectRoot, "scripts")
		var scriptName string
		var shellCmd *exec.Cmd

		if runtime.GOOS == "windows" {
			scriptName = "setup_ide.bat"
			scriptPath := filepath.Join(scriptsDir, scriptName)
			// Execute batch file using cmd.exe
			shellCmd = exec.Command("cmd.exe", "/C", scriptPath)
		} else { // Linux or macOS
			scriptName = "setup_ide.sh"
			scriptPath := filepath.Join(scriptsDir, scriptName)
			// Ensure script is executable first (best effort)
			_ = os.Chmod(scriptPath, 0755)
			// Execute shell script directly or via bash
			shellCmd = exec.Command("bash", scriptPath) // Use bash for consistency
		}

		// 3. Check if script exists
		scriptFullPath := filepath.Join(scriptsDir, scriptName)
		if _, err := os.Stat(scriptFullPath); os.IsNotExist(err) {
			color.Red("Setup script not found: %s", scriptFullPath)
			os.Exit(1)
		}
		color.Green("  [OK] Found setup script: %s", scriptName)

		// 4. Execute the script
		color.Cyan("Running %s...", scriptName)
		fmt.Println("--- Script Output Start ---")

		// Set working directory for the script to the project root
		shellCmd.Dir = projectRoot
		// Stream output directly to user's console
		shellCmd.Stdout = os.Stdout
		shellCmd.Stderr = os.Stderr

		err = shellCmd.Run()

		fmt.Println("--- Script Output End ---")

		if err != nil {
			if exitErr, ok := err.(*exec.ExitError); ok {
				color.Red("Setup script %s exited with error (Code: %d).", scriptName, exitErr.ExitCode())
				os.Exit(exitErr.ExitCode())
			} else {
				color.Red("Error running setup script %s: %v", scriptName, err)
				os.Exit(1)
			}
		} else {
			color.Green("Setup script %s completed successfully.", scriptName)
		}
	},
}

func init() {
	// No specific flags for setup command itself
}

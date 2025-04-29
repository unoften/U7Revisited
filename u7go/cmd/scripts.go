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

var (
	fixRequires bool // Flag variable
)

// scriptsCmd represents the scripts command
var scriptsCmd = &cobra.Command{
	Use:   "scripts",
	Short: "Run utility scripts.",
	Long:  `Provides access to utility scripts located in the 'scripts/' directory.`,
	Run: func(cmd *cobra.Command, args []string) {
		// Check which flag was passed
		if fixRequires {
			runScript("check_lua_requires") // Pass base name without extension
		} else {
			color.Yellow("No script specified. Available scripts:")
			// Manually list available script flags here for now
			color.Yellow("  --fix-requires   : Check and fix missing Lua require() statements.")
			cmd.Help() // Show the command's own help which includes flags
		}
	},
}

// runScript executes a utility script based on OS
func runScript(baseScriptName string) {
	color.Cyan("--- Running Utility Script: %s ---", baseScriptName)

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
		scriptName = baseScriptName + ".bat"
		scriptPath := filepath.Join(scriptsDir, scriptName)
		shellCmd = exec.Command("cmd.exe", "/C", scriptPath)
	} else { // Linux or macOS
		scriptName = baseScriptName + ".sh"
		scriptPath := filepath.Join(scriptsDir, scriptName)
		_ = os.Chmod(scriptPath, 0755) // Best effort
		shellCmd = exec.Command("bash", scriptPath)
	}

	// 3. Check if script exists
	scriptFullPath := filepath.Join(scriptsDir, scriptName)
	if _, err := os.Stat(scriptFullPath); os.IsNotExist(err) {
		color.Red("Utility script not found: %s", scriptFullPath)
		os.Exit(1)
	}
	color.Green("  [OK] Found script: %s", scriptName)

	// 4. Execute the script
	color.Cyan("Running %s...", scriptName)
	fmt.Println("--- Script Output Start ---")

	shellCmd.Dir = projectRoot
	shellCmd.Stdout = os.Stdout
	shellCmd.Stderr = os.Stderr

	err = shellCmd.Run()

	fmt.Println("--- Script Output End ---")

	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			color.Red("Script %s exited with error (Code: %d).", scriptName, exitErr.ExitCode())
			os.Exit(exitErr.ExitCode())
		} else {
			color.Red("Error running script %s: %v", scriptName, err)
			os.Exit(1)
		}
	} else {
		color.Green("Script %s completed successfully.", scriptName)
	}
}

func init() {
	// Define flags for the scripts command
	scriptsCmd.Flags().BoolVar(&fixRequires, "fix-requires", false, "Check and fix missing Lua require() statements.")
	// Add other script flags here if needed later
}

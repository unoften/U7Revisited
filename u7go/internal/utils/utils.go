package utils

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"

	"github.com/fatih/color"
)

// ProjectRoot finds the project root directory by looking for .git
// Starts from the executable's directory and goes up.
func ProjectRoot() (string, error) {
	exePath, err := os.Executable()
	if err != nil {
		return "", fmt.Errorf("failed to get executable path: %w", err)
	}

	// Start searching from the directory containing the executable
	// which should be inside `u7go` when built by the wrapper.
	searchDir := filepath.Dir(exePath)

	for i := 0; i < 10; i++ { // Limit depth to prevent infinite loops
		gitPath := filepath.Join(searchDir, ".git")
		if _, err := os.Stat(gitPath); err == nil {
			// If .git exists, the current searchDir is the project root
			return searchDir, nil
		}

		// Go up one level
		parentDir := filepath.Dir(searchDir)
		if parentDir == searchDir { // Reached the top level (e.g., '/')
			break
		}
		searchDir = parentDir
	}

	return "", fmt.Errorf("project root with .git marker not found ascending from executable path")
}

// CheckDependencies verifies that required external commands are available.
func CheckDependencies(deps ...string) error {
	color.Cyan("--- Checking Dependencies ---")
	allFound := true
	for _, dep := range deps {
		path, err := exec.LookPath(dep)
		if err != nil {
			color.Red("  [ERROR] Dependency not found: %s", dep)
			allFound = false
		} else {
			color.Green("  [OK] Found %s at %s", dep, path)
		}
	}
	if !allFound {
		return fmt.Errorf("required dependencies missing, please install them and check your PATH")
	}
	color.Green("--- All checked dependencies found --- \n")
	return nil
}

// GetCompiler checks for standard C++ compilers.
// Returns the name of the found compiler or an error.
// Note: This is a basic check; Meson handles the actual compiler selection.
func GetCompiler() (string, error) {
	compilers := []string{}
	if runtime.GOOS == "windows" {
		// On Windows, typically cl.exe (MSVC) or g++.exe/clang++.exe (MinGW/Clang)
		compilers = []string{"cl", "g++", "clang++"}
	} else {
		// On Linux/macOS
		compilers = []string{"g++", "clang++"}
	}

	for _, compiler := range compilers {
		if _, err := exec.LookPath(compiler); err == nil {
			return compiler, nil // Found one
		}
	}
	return "", fmt.Errorf("no suitable C++ compiler (cl, g++, clang++) found in PATH")
}

// RunCommand executes an external command, streaming its output.
// Deprecated: Prefer direct exec.Command usage for better output control.
func RunCommand(cmdName string, args ...string) error {
	color.Cyan("--> Executing: %s %v", cmdName, args)
	cmd := exec.Command(cmdName, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		color.Red("Error running command %s: %v", cmdName, err)
		return err
	}
	color.Green("Command finished successfully.")
	return nil
}

// copyFile helper function
func CopyFile(src, dst string) error {
	sourceFileStat, err := os.Stat(src)
	if err != nil {
		return err
	}
	if !sourceFileStat.Mode().IsRegular() {
		return fmt.Errorf("%s is not a regular file", src)
	}

	source, err := os.Open(src)
	if err != nil {
		return err
	}
	defer source.Close()

	// Create destination file, truncate if exists
	destination, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer destination.Close()

	_, err = io.Copy(destination, source)
	return err
}

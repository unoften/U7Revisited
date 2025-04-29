package cmd

import (
	"os"
	"path/filepath"

	"github.com/fatih/color"
	"github.com/spf13/cobra"
	"github.com/unoften/U7Revisited/u7go/internal/utils"
)

// cleanCmd represents the clean command
var cleanCmd = &cobra.Command{
	Use:   "clean",
	Short: "Clean the build directory (debug or release).",
	Long:  `Removes the Meson build output directory for the specified build type (default: release).`,
	Run: func(cmd *cobra.Command, args []string) {
		color.Cyan("--- Clean Task (%s) ---", buildType)

		projectRoot, err := utils.ProjectRoot()
		if err != nil {
			color.Red("Error finding project root: %v", err)
			os.Exit(1)
		}

		buildDirName := "build-" + buildType
		buildDirPath := filepath.Join(projectRoot, buildDirName)

		color.Yellow("Attempting to remove directory: %s", buildDirPath)

		// Check if directory exists before trying to remove
		if _, err := os.Stat(buildDirPath); os.IsNotExist(err) {
			color.Green("Directory %s does not exist, nothing to clean.", buildDirPath)
			return // Success, nothing to do
		}

		err = os.RemoveAll(buildDirPath)
		if err != nil {
			color.Red("Error removing directory %s: %v", buildDirPath, err)
			os.Exit(1)
		}

		color.Green("Successfully removed directory: %s", buildDirPath)
	},
}

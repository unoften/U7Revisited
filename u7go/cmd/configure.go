package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"time" // Needed for spinner

	"github.com/briandowns/spinner"
	"github.com/fatih/color"
	"github.com/spf13/cobra"
	"github.com/unoften/U7Revisited/u7go/internal/utils"
)

// configureCmd represents the configure command
var configureCmd = &cobra.Command{
	Use:   "configure",
	Short: "Force re-configure the Meson build directory.",
	Long: `Forces Meson to re-run the setup/configuration step for an existing build directory
using the '--reconfigure' flag. This is useful after changing Meson build files.`,
	Run: func(cmd *cobra.Command, args []string) {
		color.Cyan("--- Configure Task (%s) ---", buildType)

		// Validate buildType
		if buildType != "debug" && buildType != "release" {
			color.Red("Invalid build type specified: %s. Use 'debug' or 'release'.", buildType)
			os.Exit(1)
		}

		// 1. Check Core Dependencies (Meson)
		deps := []string{"meson"}
		if err := utils.CheckDependencies(deps...); err != nil {
			color.Red("Dependency check failed: %v", err)
			os.Exit(1)
		}
		color.Green("  [OK] Found Meson.")

		// 2. Find Project Root
		projectRoot, err := utils.ProjectRoot()
		if err != nil {
			color.Red("Error finding project root: %v", err)
			os.Exit(1)
		}

		// 3. Determine build path
		buildDirName := "build-" + buildType
		buildDirPath := filepath.Join(projectRoot, buildDirName)

		// 4. Check if build directory EXISTS (opposite of build command)
		if _, err := os.Stat(buildDirPath); os.IsNotExist(err) {
			color.Red("Build directory %s does not exist.", buildDirName)
			color.Yellow("Please run 'u7 build --buildtype=%s' first to create it.", buildType)
			os.Exit(1)
		}
		color.Green("Found build directory %s.", buildDirName)

		// 5. Reconfigure with Meson
		color.Cyan("Running Meson reconfigure in %s...", buildDirName)

		// --- Spinner ---
		s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
		s.Suffix = " Reconfiguring..."
		s.Color("blue")
		s.Start()
		// --- End Spinner ---

		// Use 'meson setup --reconfigure <builddir>'
		mesonConfigureCmd := exec.Command("meson", "setup", "--reconfigure", buildDirName)
		mesonConfigureCmd.Dir = projectRoot // Run from project root

		configureOutputBytes, configureErr := mesonConfigureCmd.CombinedOutput()

		s.Stop() // Stop spinner

		if configureErr != nil {
			color.Red("Meson reconfigure failed:\n%s", string(configureOutputBytes))
			os.Exit(1)
		}

		color.Green("\nMeson reconfigure successful for %s.", buildDirName)
		// Print output for user confirmation
		fmt.Println("--- Meson Output ---")
		fmt.Print(string(configureOutputBytes))
		fmt.Println("--- End Meson Output ---")
	},
}

func init() {
	// This command uses the buildType flag defined in rootCmd
}

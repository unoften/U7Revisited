package cmd

import (
	"fmt"
	"os"
	"strings"

	cc "github.com/ivanpirog/coloredcobra"
	"github.com/spf13/cobra"
)

// Flags persistent across all commands
var (
	buildType string
	warnings  bool
)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "u7",
	Short: "Wrapper script using Go for U7Revisited development tasks.",
	Long: `This is the main command interface for U7Revisited development,
invoked via the 'u7' (Linux/macOS) or 'u7.bat' (Windows) wrapper scripts.

It provides a cross-platform way to build, run, clean, and manage the project,
replacing the older shell/batch scripts by executing the underlying 'u7go' program.

Note on Updating:
  To update the underlying 'u7go' program itself (after source changes),
  use the wrapper-specific command: u7 update`,
	// If run without subcommands, show help
	Run: func(cmd *cobra.Command, args []string) {
		cmd.Help()
	},
	// Silence errors because we handle them explicitly in Execute()
	SilenceErrors: true,
	// Silence usage for the same reason
	SilenceUsage: true,
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	// --- Initialize coloredcobra ---
	// Using colors inspired by the bash script
	cc.Init(&cc.Config{
		RootCmd:         rootCmd,
		Headings:        cc.HiBlue + cc.Bold + cc.Underline,
		Commands:        cc.HiYellow + cc.Bold,
		CmdShortDescr:   cc.White,
		Example:         cc.Italic,
		ExecName:        cc.Bold,
		Flags:           cc.Bold,   // Style for flags like --debug
		FlagsDataType:   cc.Italic, // Style for flag data types
		FlagsDescr:      cc.White,  // Style for flag descriptions
		Aliases:         cc.HiMagenta,
		NoExtraNewlines: false,
		NoBottomNewline: true,
	})

	// Customize Usage template to consistently show 'u7'
	usageTemplate := rootCmd.UsageTemplate()
	newUsageTemplate := strings.ReplaceAll(usageTemplate, "{{.CommandPath}}", "u7") // Replace placeholder
	rootCmd.SetUsageTemplate(newUsageTemplate)
	// Also customize Help template if needed for other occurrences
	helpTemplate := rootCmd.HelpTemplate()
	newHelpTemplate := strings.ReplaceAll(helpTemplate, "{{.CommandPath}}", "u7")
	rootCmd.SetHelpTemplate(newHelpTemplate)

	err := rootCmd.Execute()
	if err != nil {
		// Use fmt.Fprintln to ensure the error goes to stderr
		// We could use fatih/color here later for red errors
		fmt.Fprintln(os.Stderr, "Error:", err)
		os.Exit(1)
	}
}

func init() {
	// Define persistent flags available to all commands
	rootCmd.PersistentFlags().StringVarP(&buildType, "buildtype", "b", "release", "Build type (debug or release)")
	rootCmd.PersistentFlags().BoolVar(&warnings, "warnings", false, "Show compiler warnings in build summary")
	// Potentially add --configure flag here later if needed globally

	// Add child commands here (placeholders for now)
	rootCmd.AddCommand(buildCmd)
	rootCmd.AddCommand(cleanCmd)
	rootCmd.AddCommand(configureCmd)
	rootCmd.AddCommand(healthcheckCmd)
	rootCmd.AddCommand(runCmd)
	rootCmd.AddCommand(scriptsCmd)
	rootCmd.AddCommand(setupCmd)
}

// Helper function (example, move to utils later)
func printError(msg string, err error) {
	// TODO: Use fatih/color for red output
	if err != nil {
		fmt.Fprintf(os.Stderr, "[U7GO ERROR] %s: %v\n", msg, err)
	} else {
		fmt.Fprintf(os.Stderr, "[U7GO ERROR] %s\n", msg)
	}
}

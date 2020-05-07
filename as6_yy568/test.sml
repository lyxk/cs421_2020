CM.make "sources.cm";
Main.compile( List.nth (CommandLine.arguments(), 0) );

OS.Process.exit(OS.Process.success)

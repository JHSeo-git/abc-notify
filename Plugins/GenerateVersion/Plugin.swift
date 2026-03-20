import PackagePlugin

@main
struct GenerateVersionPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        let outputDir = context.pluginWorkDirectory.appending("GeneratedSources")
        let versionFile = context.package.directory.appending("VERSION")

        return [
            .prebuildCommand(
                displayName: "Generate abc-notify version source",
                executable: Path("/bin/sh"),
                arguments: [
                    "-c",
                    """
                    set -euo pipefail
                    mkdir -p "$1"
                    VERSION="$(tr -d '\\r\\n' < "$2")"
                    cat > "$1/GeneratedVersion.swift" <<EOF
                    enum GeneratedVersion {
                        static let current = "$VERSION"
                    }
                    EOF
                    """,
                    "--",
                    outputDir.string,
                    versionFile.string,
                ],
                outputFilesDirectory: outputDir
            )
        ]
    }
}

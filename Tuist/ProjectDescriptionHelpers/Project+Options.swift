import ProjectDescription

extension Project.Options.TextSettings {
    static var textOptions: Project.Options.TextSettings {
        .textSettings(
            usesTabs: false,
            indentWidth: 4,
            tabWidth: 4,
            wrapsLines: true
        )
    }
}

public extension Project.Options {
    static var musicPlayerOptions: Project.Options {
        .options(
            automaticSchemesOptions: .enabled(
                targetSchemesGrouping: .notGrouped,
                codeCoverageEnabled: true,
                testingOptions: [
                    .parallelizable,
                    .randomExecutionOrdering,
                ]
            ),
            developmentRegion: "en_US",
            disableBundleAccessors: true,
            disableShowEnvironmentVarsInScriptPhases: false,
            disableSynthesizedResourceAccessors: true,
            textSettings: .textOptions
        )
    }
}

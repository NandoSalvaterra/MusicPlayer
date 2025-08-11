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

public extension Settings {
    static var projectSettings: Settings {
        .settings(
            base: [
                "SWIFT_VERSION": "6.0",
                "SWIFT_STRICT_CONCURRENCY": "complete",

                "SWIFT_COMPILATION_MODE": "wholemodule",
                "SWIFT_TREAT_WARNINGS_AS_ERRORS": "NO",
            ],
            configurations: [
                .debug(
                    name: "Debug",
                    settings: [
                        "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG"
                    ]
                ),
                .release(
                    name: "Release",
                    settings: [
                        "SWIFT_OPTIMIZATION_LEVEL": "-O"
                    ]
                )
            ]
        )
    }
}

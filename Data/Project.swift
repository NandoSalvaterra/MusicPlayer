import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Data",
    options: .musicPlayerOptions,
    settings: .projectSettings,
    targets: [
        Target.target(
            name: "Data",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.musicplayer.data",
            deploymentTargets: .iOS("17.0"),
            infoPlist: "SupportFiles/Data-Info.plist",
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Network", path: "../Network")
            ],
            settings: .frameworkTargetSettings
        ),
        .target(
            name: "DataTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.musicplayer.data.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: "Tests/SupportFiles/DataTests-Info.plist",
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "Data")],
            settings: .projectSettings
        )
    ]
)


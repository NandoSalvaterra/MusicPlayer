import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Network",
    options: .musicPlayerOptions,
    settings: .projectSettings,
    targets: [
        Target.target(
            name: "Network",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.musicplayer.network",
            deploymentTargets: .iOS("17.0"),
            infoPlist: "SupportFiles/Network-Info.plist",
            sources: ["Sources/**"],
            dependencies: [],
            settings: .projectSettings
        ),
        .target(
            name: "NetworkTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.musicplayer.network.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: "Tests/SupportFiles/NetworkTests-Info.plist",
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "Network")],
            settings: .projectSettings
        )
    ]
)

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "App",
    options: .musicPlayerOptions,
    settings: .projectSettings,
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: "com.musicplayer.app",
            deploymentTargets: .iOS("17.0"),
            infoPlist: "SupportFiles/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "Network", path: "../Network")
            ],
            settings: .projectSettings
        ),
        .target(
            name: "AppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.musicplayer.app.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: "Tests/SupportFiles/AppTests-Info.plist",
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "App")],
            settings: .projectSettings
        ),
    ]
)

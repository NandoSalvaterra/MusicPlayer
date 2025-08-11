import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "App",
    options: .musicPlayerOptions,
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: "com.musicplayer.app",
            infoPlist: "SupportFiles/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
            //.project(target: "Network", path: "../Network")
            ]
        ),
        .target(
            name: "AppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.musicplayer.app.tests",
            infoPlist: "Tests/SupportFiles/AppTests-Info.plist",
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "App")]
        ),
    ]
)

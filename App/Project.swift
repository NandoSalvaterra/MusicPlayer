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
            bundleId: "com.musicplayer",
            infoPlist: "SupportFiles/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
              //  .project(target: "Domain", path: "../Domain")
            ]
        ),
        .target(
            name: "AppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.musicplayer.tests",
            infoPlist: "Tests/SupportFiles/AppTests-Info.plist",
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "App")]
        ),
    ]
)

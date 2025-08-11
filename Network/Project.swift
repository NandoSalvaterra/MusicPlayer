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
            headers: .headers(public: ["Sources/Header/Network.h"]),
            dependencies: [],
            settings: .projectSettings
        )
    ]
)

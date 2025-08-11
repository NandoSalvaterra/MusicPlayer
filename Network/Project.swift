import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Network",
    options: .musicPlayerOptions,
    targets: [
        Target.target(
            name: "Network",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.musicplayer.network",
            deploymentTargets: .iOS("16.0"),
            infoPlist: "SupportFiles/Network-Info.plist",
            sources: ["Sources/**"],
            headers: .headers(public: ["Sources/Header/Network.h"]),
            dependencies: []
        )
    ]
)

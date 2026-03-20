// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "abc-notify-helper",
    platforms: [.macOS(.v13)],
    targets: [
        .target(
            name: "ABCNotifyLib",
            path: "Sources/ABCNotifyLib",
            linkerSettings: [
                .linkedFramework("CoreGraphics"),
                .linkedFramework("AppKit"),
                .linkedFramework("ApplicationServices"),
            ],
            plugins: ["GenerateVersionPlugin"]
        ),
        .executableTarget(
            name: "abc-notify-native",
            dependencies: ["ABCNotifyLib"],
            path: "Sources/abc-notify-native",
            linkerSettings: [
                .linkedFramework("CoreGraphics"),
                .linkedFramework("AppKit"),
                .linkedFramework("ApplicationServices"),
            ]
        ),
        .testTarget(
            name: "ABCNotifyTests",
            dependencies: ["ABCNotifyLib"],
            path: "Tests/ABCNotifyTests"
        ),
        .plugin(
            name: "GenerateVersionPlugin",
            capability: .buildTool(),
            path: "Plugins/GenerateVersion"
        )
    ]
)

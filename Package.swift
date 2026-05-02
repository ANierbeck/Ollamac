// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Ollamac",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-testing.git", .upToNextMajor(from: "0.15.0")),
        .package(url: "https://github.com/sindresorhus/Defaults.git", from: "8.2.0"),
        .package(url: "https://github.com/raspu/Highlightr.git", from: "2.2.1"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui.git", from: "2.3.1"),
        .package(url: "https://github.com/kevinhermawan/ViewState.git", from: "1.2.2"),
        .package(url: "https://github.com/kevinhermawan/ViewCondition.git", from: "1.0.5"),
        .package(url: "https://github.com/siteline/swiftui-introspect.git", from: "1.3.0"),
        .package(url: "https://github.com/kevinhermawan/AppInfo.git", from: "1.0.2"),
        .package(url: "https://github.com/kevinhermawan/ChatField.git", from: "3.0.4"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.7.0"),
        .package(url: "https://github.com/gonzalezreal/NetworkImage", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "OllamaKit",
            path: "Sources/OllamaKit/Sources",
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=minimal"])
            ]
        ),
        .executableTarget(
            name: "Ollamac",
            dependencies: [
                "OllamaKit",
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "Highlightr", package: "Highlightr"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "ViewState", package: "ViewState"),
                .product(name: "ViewCondition", package: "ViewCondition"),
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
                .product(name: "AppInfo", package: "AppInfo"),
                .product(name: "ChatField", package: "ChatField"),
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "NetworkImage", package: "NetworkImage")
            ],
            path: "Ollamac",
            exclude: ["Preview Content", "Resources"],
            resources: [.process("Resources")],
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=minimal"])
            ]
        ),
        .testTarget(
            name: "OllamacTests",
            dependencies: [
                "Ollamac",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "OllamacTests",
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=minimal"])
            ]
        )
    ]
)

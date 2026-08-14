// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AmityUIKit-OpenSource",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AmityUIKit4",
            targets: ["AmityUIKit4"]
        ),
    ],
    targets: [
        .target(
            name: "AmityUIKit4",
            dependencies: [
                "AmitySDK",
                "AmityLiveKit",
                "LiveKitWebRTC"
            ],
            path: "UpstraUIKit/AmityUIKit4/AmityUIKit4"
        ),
        .binaryTarget(
            name: "AmitySDK",
            url: "https://sdk.amity.co/sdk-release/ios-uikit-frameworks/4.26.0/AmitySDK.xcframework.zip",
            checksum: "2486e169e425770eac60e824d575e3a137b76a10e5e3f9a35bb0fa1da3457672"
        ),
        .binaryTarget(
            name: "AmityLiveKit",
            url: "https://sdk.amity.co/sdk-release/ios-frameworks/d7485f57/AmityLiveKit.xcframework.zip",
            checksum: "b5c6f8c569f434d8bbb966acdc62fdcf0bb456d84bf89f91995d95f5181c5b5e"
        ),
        .binaryTarget(
            name: "LiveKitWebRTC",
            url: "https://sdk.amity.co/sdk-release/ios-frameworks/d7485f57/LiveKitWebRTC.xcframework.zip",
            checksum: "b4787d18a681ef7a723aed3b0b246f54eba0f3b59d56a0a35b9905286af9e004"
        )
    ]
)

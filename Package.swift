// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FID",
    platforms: [
        // Only add support for iOS 11 and up.
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "FID", targets: ["FTSDK", "FTSDKCoreKit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SwiftKickMobile/SwiftMessages.git", exact: "9.0.6"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "10.22.1"),
        .package(url: "https://github.com/facebook/facebook-ios-sdk.git", exact: "17.0.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", exact: "7.0.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", exact: "5.1.0"),
        //         .package(url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework.git", exact: "6.14.0"),
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(name: "AppsFlyerLib", 
                      url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework/releases/download/6.14.0/AppsFlyerLib-Static-SPM.xcframework.zip",
                      checksum: "d7fdf61996dacb7787506305b6c541197ede64fcc4528c41842d9a507bd1b94b"),
//        .binaryTarget(name: "FacebookLogin",
//                      url: "https://github.com/facebook/facebook-ios-sdk/releases/download/v17.0.0/FacebookSDK-Static_XCFramework.zip",
//                      checksum: "81affeee4efa27bdd6ff1868030b9a3b3085624dddb2dad2c1cbeafa4155777f"),
        .binaryTarget(name: "FTSDKCoreKit", path: "Sources/FTSDKCoreKit.xcframework"),
        //        .binaryTarget(name: "GT3Captcha", path: "Sources/GT3Captcha.xcframework"),
        .target(
            name: "FTSDK",
            dependencies: ["FTSDKCoreKit",
                           "SwiftMessages",
                           "AppsFlyerLib",
//                           "FacebookLogin",
//                           "FTSDKCoreKit",
                           .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                           .product(name: "GoogleSignIn", package: "googlesignin-ios"),
                           .product(name: "FacebookLogin", package: "facebook-ios-sdk"),
                           .product(name: "SDWebImage", package: "SDWebImage"),
//                           .product(name: "AppsFlyerLib", package: "AppsFlyerFramework"),
                           .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                           .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                           .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                           .product(name: "FirebaseDynamicLinks", package: "firebase-ios-sdk"),
                          ])
        
    ]
)

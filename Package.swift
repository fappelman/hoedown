// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Hoedown",
    platforms: [
        .macOS(.v10_14)
    ],
    products: [
      .library(
          name: "Hoedown",
          targets: ["Hoedown"]),
      .library(
          name: "CHoedown",
          targets: ["CHoedown"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "CHoedown", dependencies: [ ]),
        .target(name: "Hoedown", dependencies: [ "CHoedown" ])
    ]
)

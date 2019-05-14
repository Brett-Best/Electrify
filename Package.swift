// swift-tools-version:5.0

import PackageDescription

let projectName = "Electrify"

let package = Package(
  name: projectName,
  dependencies: [
    .package(url: "https://github.com/uraimo/SwiftyGPIO.git", .branch("master")),
    .package(url: "https://github.com/Bouke/HAP.git", .branch("master"))
  ],
  targets: [
    .target(
      name: projectName,
      dependencies: ["SwiftyGPIO", "HAP"]),
    ]
)

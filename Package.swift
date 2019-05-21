// swift-tools-version:5.0

import PackageDescription

let projectName = "Electrify"

let package = Package(
  name: projectName,
  dependencies: [
    .package(url: "https://github.com/uraimo/SwiftyGPIO.git", .branch("next_release")),
    .package(url: "https://github.com/Brett-Best/dhtxx.git", .branch("feature/swift-5")),
    .package(url: "https://github.com/Brett-Best/HAP.git", .branch("feature/characteristic-callbacks")),
    .package(url: "https://github.com/pvieito/PythonKit.git", .branch("master")),
    .package(url: "https://github.com/onevcat/Rainbow", .branch("master"))
  ],
  targets: [
    .target(
      name: projectName,
      dependencies: ["SwiftyGPIO", "dhtxx", "HAP", "PythonKit", "Rainbow"]),
    ]
)

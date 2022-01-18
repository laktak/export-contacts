// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ExportContacts",
  platforms: [
    .macOS(.v12)
  ],
  products: [
    .executable(
      name: "export-contacts",
      targets: ["ExportContacts"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/SwiftyContacts/SwiftyContacts.git", .upToNextMajor(from: "4.0.0"))
  ],
  targets: [
    .executableTarget(
      name: "ExportContacts",
      dependencies: [
        .product(name: "SwiftyContacts", package: "SwiftyContacts")
      ]
    )
  ]
)

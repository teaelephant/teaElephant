// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "TeaElephantSchema",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_14),
    .tvOS(.v12),
    .watchOS(.v5),
  ],
  products: [
    .library(name: "TeaElephantSchema", targets: ["TeaElephantSchema"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apollographql/apollo-ios", exact: "1.22.0"),
  ],
  targets: [
    .target(
      name: "TeaElephantSchema",
      dependencies: [
        .product(name: "ApolloAPI", package: "apollo-ios"),
      ],
      path: "./Sources"
    ),
  ]
)

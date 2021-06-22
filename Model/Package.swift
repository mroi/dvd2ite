// swift-tools-version:5.5
import PackageDescription

let package = Package(
	name: "Model",
	platforms: [
		.macOS(.v11)
	],
	products: [
		.library(name: "MovieArchiveModel", targets: ["MovieArchiveModel"])
	],
	targets: [
		.target(name: "MovieArchiveModel", path: ".")
	]
)

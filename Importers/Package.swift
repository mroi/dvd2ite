// swift-tools-version:5.5
import PackageDescription

let package = Package(
	name: "Importers",
	platforms: [
		.macOS(.v11)
	],
	products: [
		.library(name: "MovieArchiveImporters", targets: ["MovieArchiveImporters"])
	],
	targets: [
		.target(name: "MovieArchiveImporters", path: ".")
	]
)

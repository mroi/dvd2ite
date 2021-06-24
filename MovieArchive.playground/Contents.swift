import Foundation
import MovieArchiveModel
import MovieArchiveImporters
import MovieArchiveExporters


let source = URL(fileURLWithPath: ".")
let transform = Transform(importer: try! Importer(fromSource: source), exporter: Exporter())

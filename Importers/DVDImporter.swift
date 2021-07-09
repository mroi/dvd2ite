import Foundation
import MovieArchiveModel
import MovieArchiveConverter


struct DVDImporter: ImportPass {

	public init(fromSource url: URL) throws {
		let _ = try DVDReader(fromSource: url)
	}
}

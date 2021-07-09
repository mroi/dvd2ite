@testable import MovieArchiveImporters
@testable import MovieArchiveConverter
import XCTest


class DVDImporterTests: XCTestCase {

	override func setUp() {
		ConverterClient.injectedProxy = nil
	}
}

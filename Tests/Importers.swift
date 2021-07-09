@testable import MovieArchiveImporters
@testable import MovieArchiveConverter
import XCTest


class DVDImporterTests: XCTestCase {

	override func setUp() {
		ConverterClient.injectedProxy = nil
	}

	func testDVDReaderInitDeinit() {
		let openCall = expectation(description: "open should be called")
		let closeCall = expectation(description: "close should be called")

		class ReaderMock: ConverterDVDReader {
			let openCall: XCTestExpectation
			let closeCall: XCTestExpectation

			init(withExpectations expectations: XCTestExpectation...) {
				openCall = expectations[0]
				closeCall = expectations[1]
			}
			func open(_: URL, completionHandler done: @escaping (UUID?) -> Void) {
				openCall.fulfill()
				done(UUID())
			}
			func close(_: UUID) {
				closeCall.fulfill()
			}
		}

		ConverterClient.injectedProxy = ReaderMock(withExpectations: openCall, closeCall)

		let source = URL(fileURLWithPath: ".")
		let _ = try? DVDReader(fromSource: source)

		waitForExpectations(timeout: .infinity)
	}

	func testUnsupportedSource() {
		let source = URL(fileURLWithPath: "/var/empty")
		XCTAssertThrowsError(try DVDImporter(fromSource: source)) {
			XCTAssertEqual($0 as! Importer.Error, Importer.Error.sourceNotSupported)
		}
	}
}

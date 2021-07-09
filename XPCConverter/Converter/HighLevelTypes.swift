import Foundation


/* MARK: DVDReader */

/// Reads and interprets DVD data structures.
///
/// This client-side type accesses `libdvdread` functionality in the XPC
/// converter service. It manages the lifetime of the corresponding `libdvdread`
/// state.
public final class DVDReader: ConverterClient<ConverterDVDReader> {

	private var readerStateID: UUID!

	/// Initializes a DVD reader for the given URL
	public init(fromSource url: URL) throws {
		super.init()

		var done = false
		// invoke the converter operation
		var id: UUID?
		remote.open(url) { result in
			DispatchQueue.main.async { id = result; done = true }
		}

		// wait for asynchronous operation to finish
		while !done { RunLoop.current.run(mode: .default, before: .distantFuture) }

		guard let id = id else {
			throw ConverterError.sourceNotSupported
		}

		readerStateID = id
	}

	deinit {
		if readerStateID != nil {
			remote.close(readerStateID)
		}
	}
}

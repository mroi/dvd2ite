import Foundation
import MovieArchiveConverter
import LibDVDRead


extension ConverterImplementation: ConverterDVDReader {

	public func open(_ url: URL, completionHandler done: @escaping (UUID?) -> Void) {
		if url.isFileURL, let reader = DVDOpen(url.path) {
			// make sure this looks like a DVD
			var statbuf = dvd_stat_t()
			let result = DVDFileStat(reader, 0, DVD_READ_INFO_FILE, &statbuf)

			if result == 0 {
				// valid DVD, remember reader state and return unique handle
				let id = UUID()
				state.updateValue(reader, forKey: id)
				// keep XPC service alive as long as there is active reader state
				xpc_transaction_begin()

				done(id)
				return
			}
		}
		done(.none)
	}

	public func close(_ id: UUID) {
		if let reader = state[id] {
			DVDClose(reader)
			xpc_transaction_end()
		}
	}
}

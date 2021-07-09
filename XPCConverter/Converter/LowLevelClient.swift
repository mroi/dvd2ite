import Foundation
import Combine


/// Functions from `libdvdread` for reading and interpreting DVD data structures.
@objc public protocol ConverterDVDReader {
	func open(_: URL, completionHandler: @escaping (UUID?) -> Void)
	func close(_: UUID)
}

/// Aggregate interface of all converter interfaces.
@objc public protocol ConverterInterface: ConverterDVDReader {}


/// Low-level access the converter functionality.
///
/// To isolate potentially unsafe code, complex conversion operations are
/// provided by an XPC service. These operations are grouped in interface
/// protocols. A client-side proxy object implementing one of these interfaces
/// is provided by an instance of this class.
///
/// At the same time, the XPC service can send asynchronous feedback to the
/// client by way of the `ConverterPublisher`.
///
/// - Remark: These low-level XPC protocols form an hourglass interface which
///   is meant to be augmented with client-side currency types like `DVDReader`.
///   This empty `enum` acts as a namespace for factory functions.
public class ConverterClient<ProxyInterface> {

	/// Publisher to receive status updates from the converter service.
	public let publisher: ConverterPublisher

	let remote: ProxyInterface
	private let connection: NSXPCConnection
	private let subscription: AnyCancellable?

	/// Sets up a client instance managing one XPC connection.
	init() {
#if DEBUG
		if let proxy = ConverterClient<Any>.injectedProxy {
			remote = proxy as! ProxyInterface
			publisher = ConverterClient<Any>.injectedPublisher
			connection = NSXPCConnection()
			subscription = nil
			return
		}
#endif

		let returnChannel = ReturnImplementation()
		connection = ConverterClient<ProxyInterface>.connection()
		connection.remoteObjectInterface = NSXPCInterface(with: ConverterInterface.self)
		connection.exportedInterface = NSXPCInterface(with: ReturnInterface.self)
		connection.exportedObject = returnChannel
		connection.resume()

		remote = connection.remoteObjectProxy as! ProxyInterface
		publisher = returnChannel.publisher

		// invalidate the connection whenever the publisher completes
		subscription = publisher.sink { [weak connection] _ in
			connection?.invalidate()
		} receiveValue: { _ in }
	}

	deinit {
		connection.invalidate()
	}

	/// Creates a connection to the XPC service.
	private static func connection() -> NSXPCConnection {
#if DEBUG
		if Bundle.main.bundleIdentifier == "com.apple.dt.Xcode.PlaygroundStub-macosx" {
			// Playground execution: XPC service needs to be manually registered
			let connection = NSXPCConnection(machServiceName: "de.reactorcontrol.movie-archive.converter")
			connection.invalidationHandler = {
				print("To use the Converter XPC service from a Playground, " +
					  "it needs to be manually registered with launchd:")
				print("launchctl bootstrap gui/\(getuid()) <path to Converter.xpc>")
			}
			return connection
		}
#endif
		return NSXPCConnection(serviceName: "de.reactorcontrol.movie-archive.converter")
	}
}

#if DEBUG
extension ConverterClient where ProxyInterface == Any {

	/// Injects a mock implementation for testing.
	static var injectedProxy: ProxyInterface?

	/// Injects a mock implementation for testing.
	static var injectedPublisher =
		Empty<ConverterOutput, ConverterError>(completeImmediately: false).eraseToAnyPublisher()
}
#endif

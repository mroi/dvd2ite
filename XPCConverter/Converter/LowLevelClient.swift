import Foundation


/// Functions from `libdvdread` for reading and interpreting DVD data structures.
@objc public protocol ConverterDVDReader {
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
/// - Remark: These low-level XPC protocols form an hourglass interface which
///   is meant to be augmented with client-side currency types like `DVDReader`.
///   This empty `enum` acts as a namespace for factory functions.
public class ConverterClient<ProxyInterface> {

	let remote: ProxyInterface
	private let connection: NSXPCConnection

	/// Sets up a client instance managing one XPC connection.
	init() {
		connection = ConverterClient<ProxyInterface>.connection()
		connection.remoteObjectInterface = NSXPCInterface(with: ConverterInterface.self)
		connection.resume()

		remote = connection.remoteObjectProxy as! ProxyInterface
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

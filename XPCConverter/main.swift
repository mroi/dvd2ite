import Foundation
import MovieArchiveConverter


/// Implementation of the XPC functionality.
///
/// A new implementation instance is created per connection to the XPC service.
/// Functions are called on an internal serial queue, so per instance, all
/// operations are single-threaded.
class ConverterImplementation: NSObject {

	/// Stores state of external libraries across function calls.
	var state: [UUID: OpaquePointer] = [:]

	/// Fetches the proxy object for the return channel to the client.
	static func returnChannel() -> ReturnInterface? {
		let proxy = NSXPCConnection.current()?.remoteObjectProxy
		return proxy as? ReturnInterface
	}
}

class ConverterDelegate: NSObject, NSXPCListenerDelegate {
	func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
		connection.remoteObjectInterface = NSXPCInterface(with: ReturnInterface.self)
		connection.exportedInterface = NSXPCInterface(with: ConverterInterface.self)
		connection.exportedObject = ConverterImplementation()
		connection.resume()
		return true
	}
}

let delegate = ConverterDelegate()
let listener = NSXPCListener.service()
listener.delegate = delegate
listener.resume()
fatalError("unexpected return from XPC server loop")

import Foundation

// A lightweight wrapper to allow capturing non-Sendable SDK objects
// inside closures that are imported as @Sendable. Use sparingly and
// only when you know execution stays on a safe thread/actor.
final class SendableBox<T>: @unchecked Sendable {
    let value: T
    init(_ value: T) { self.value = value }
}


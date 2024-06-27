import Foundation
import SwiftUI

#if !os(watchOS)
#if DEBUG
@available(iOS 13.0, *)
public extension SwiftUI.View {
    func enableInjection() -> some SwiftUI.View {
        _ = InjectConfiguration.load
        
        // Use AnyView in case the underlying view structure changes during injection.
        // This is only in effect in debug builds.
        return AnyView(self)
    }

    func onInjection(callback: @escaping (Self) -> Void) -> some SwiftUI.View {
        onReceive(InjectConfiguration.observer.objectWillChange, perform: {
            callback(self)
        })
        .enableInjection()
    }
}

@available(iOS 13.0, *)
@propertyWrapper @MainActor
public struct ObserveInjection: DynamicProperty {
    @ObservedObject private var iO = InjectConfiguration.observer
    public init() {}
    // Use a computed property rather than directly storing the value to work around https://github.com/swiftlang/swift/issues/62003
    public var wrappedValue: InjectConfiguration.Type { InjectConfiguration.self }
}

#else
@available(iOS 13.0, *)
public extension SwiftUI.View {
    @inlinable @inline(__always)
    func enableInjection() -> Self { self }

    @inlinable @inline(__always)
    func onInjection(callback: @escaping (Self) -> Void) -> Self {
        self
    }
}

@available(iOS 13.0, *)
@propertyWrapper @MainActor
public struct ObserveInjection: DynamicProperty {
    public init() {}
    // Use a computed property rather than directly storing the value to work around https://github.com/swiftlang/swift/issues/62003
    public var wrappedValue: InjectConfiguration.Type { InjectConfiguration.self }
}
#endif
#endif

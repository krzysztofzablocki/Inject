import Foundation
import SwiftUI

#if DEBUG
public extension SwiftUI.View {
    func enableInjection() -> some SwiftUI.View {
        _ = Inject.load
        
        // Use AnyView in case the underlying view structure changes during injection.
        // This is only in effect in debug builds.
        return AnyView(self)
    }

    func onInjection(callback: @escaping (Self) -> Void) -> some SwiftUI.View {
        onReceive(Inject.observer.objectWillChange, perform: {
            callback(self)
        })
        .enableInjection()
    }
}

@propertyWrapper
public struct ObserveInjection: DynamicProperty {
    @ObservedObject private var iO = Inject.observer
    public init() {}
    public private(set) var wrappedValue: Inject.Type = Inject.self
}

#else
public extension SwiftUI.View {
    @inlinable @inline(__always)
    func enableInjection() -> Self { self }

    @inlinable @inline(__always)
    func onInjection(callback: @escaping (Self) -> Void) -> Self {
        self
    }
}

@propertyWrapper
public struct ObserveInjection {
    public init() {}
    public private(set) var wrappedValue: Inject.Type = Inject.self
}
#endif

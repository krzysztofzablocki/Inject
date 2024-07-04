import Foundation
import Combine
import SwiftUI

#if !os(watchOS)
/// Common protocol interface for classes that support observing injection events
/// This is automatically added to all NSObject subclasses like `ViewController`s or `Window`s
public protocol InjectListener {
    associatedtype InjectInstanceType = Self

    func enableInjection()
    func onInjection(callback: @escaping (InjectInstanceType) -> Void) -> Void
}

/// Public namespace for using Inject API
public enum InjectConfiguration {
    public static var bundlePath = "/Applications/InjectionIII.app/Contents/Resources/"
    @available(iOS 13.0, *)
    public static let observer = injectionObserver
    public static let load: Void = loadInjectionImplementation
    @available(iOS 13.0, *)
    public static var animation: SwiftUI.Animation?
}

public extension InjectListener {
    /// Ensures injection is enabled
    @inlinable @inline(__always)
    func enableInjection() {
        _ = InjectConfiguration.load
    }
}

#if DEBUG
private var loadInjectionImplementation: Void = {
    guard objc_getClass("InjectionClient") == nil else { return }
    // If project has a "Build Phase" running this script, Inject should
    // work on a device (requires an InjectionIII github release 4.8.0+):
    // /Applications/InjectionIII.app/Contents/Resources/copy_bundle.sh
    if let path = Bundle.main.path(forResource:
            "iOSInjection", ofType: "bundle") ??
        Bundle.main.path(forResource:
            "macOSInjection", ofType: "bundle"),
        Bundle(path: path)?.load() == true {
        return
    }
#if os(macOS)
    let bundleName = "macOSInjection.bundle"
#elseif os(tvOS)
    let bundleName = "tvOSInjection.bundle"
#elseif os(visionOS)
    let bundleName = "xrOSInjection.bundle"
#elseif targetEnvironment(simulator)
    let bundleName = "iOSInjection.bundle"
#elseif targetEnvironment(macCatalyst)
    let bundleName = "macOSInjection.bundle"
#else
    let bundleName = "maciOSInjection.bundle"
#endif // OS and environment conditions

#if targetEnvironment(simulator) || os(macOS) || targetEnvironment(macCatalyst)

    if let bundle = Bundle(path: InjectConfiguration.bundlePath + bundleName) {
        bundle.load()
    } else {
        print("⚠️ Inject: InjectionIII bundle not found, verify if it's in \(InjectConfiguration.bundlePath)")
    }
#endif
}()

@available(iOS 13.0, *)
public class InjectionObserver: ObservableObject {
    @Published public private(set) var injectionNumber = 0
    private var cancellable: AnyCancellable?

    fileprivate init() {
        cancellable = NotificationCenter.default.publisher(for: Notification.Name("INJECTION_BUNDLE_NOTIFICATION"))
            .sink { [weak self] _ in
                if let animation = InjectConfiguration.animation {
                    withAnimation(animation) {
                        self?.injectionNumber += 1
                    }
                } else {
                    self?.injectionNumber += 1
                }
            }
    }
}

@available(iOS 13.0, *)
private let injectionObserver = InjectionObserver()
@available(iOS 13.0, *)
private var injectionObservationKey = arc4random()

public extension InjectListener where Self: NSObject {
    func onInjection(callback: @escaping (Self) -> Void) {
        guard #available(iOS 13.0, *) else {
            return
        }
        let observation = injectionObserver.objectWillChange.sink(receiveValue: { [weak self] in
            guard let self = self else { return }
            callback(self)
        })

        objc_setAssociatedObject(self, &injectionObservationKey, observation, .OBJC_ASSOCIATION_RETAIN)
    }
}

#else
@available(iOS 13.0, *)
public class InjectionObserver: ObservableObject {}
@available(iOS 13.0, *)
private let injectionObserver = InjectionObserver()
private var loadInjectionImplementation: Void = {}()

public extension InjectListener where Self: NSObject {
    @inlinable @inline(__always)
    func onInjection(callback: @escaping (Self) -> Void) {}
}
#endif // DEBUG
#endif

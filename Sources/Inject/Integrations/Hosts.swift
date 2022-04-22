#if canImport(UIKit)
import UIKit
public typealias InjectViewControllerType = UIViewController
public typealias InjectViewType = UIView
#elseif canImport(AppKit)
import AppKit
public typealias InjectViewControllerType = NSViewController
public typealias InjectViewType = NSView
#endif

#if DEBUG

extension Inject {
    public typealias ViewControllerHost = _InjectableViewControllerHost
    public typealias ViewHost = _InjectableViewHost
}

/// Usage: to create an autoreloading view controller, wrap your
/// view controller that you wish to see changes within `Inject.ViewHost`. For example,
/// If you are using a `TestViewController`, you would do the following:
/// `let myView = Inject.ViewControllerHost(TestViewController())`
/// And within the parent view, you should add the view above.
@dynamicMemberLookup
public class _InjectableViewControllerHost<Hosted: InjectViewControllerType>: InjectViewControllerType {
    public private(set) var instance: Hosted
    let constructor: () -> Hosted
    
    public init(_ constructor: @autoclosure @escaping () -> Hosted) {
        instance = constructor()
        self.constructor = constructor
        
        super.init(nibName: nil, bundle: nil)
        
        addAsChild()
        onInjection { instance in
            instance.resetHosted()
        }
    }
    
    override open func loadView() {
        view = InjectViewType(frame: .zero)
    }
    
    private func resetHosted() {
        // remove old vc from child list
#if canImport(UIKit)
        instance.willMove(toParent: nil)
#endif
        instance.view.removeFromSuperview()
        instance.removeFromParent()
        
        instance = constructor()
        addAsChild()
    }
    
    private func addAsChild() {
        // add the real content as child
        addChild(instance)
        view.addSubview(instance.view)
#if canImport(UIKit)
        instance.didMove(toParent: self)
        
        title = instance.title
        #if !os(tvOS)
        navigationItem.titleView = instance.navigationItem.titleView
        navigationItem.backButtonTitle = instance.navigationItem.backButtonTitle
        navigationItem.backBarButtonItem = instance.navigationItem.backBarButtonItem
        navigationItem.leftBarButtonItems = instance.navigationItem.leftBarButtonItems
        navigationItem.rightBarButtonItems = instance.navigationItem.rightBarButtonItems
        navigationItem.largeTitleDisplayMode = instance.navigationItem.largeTitleDisplayMode
        #endif
#endif
        
        instance.view.translatesAutoresizingMaskIntoConstraints = false
        [
            instance.view.topAnchor.constraint(equalTo: view.topAnchor),
            instance.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            instance.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            instance.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        .forEach { $0.isActive = true }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Hosted, T>) -> T {
        get { instance[keyPath: keyPath] }
        set { instance[keyPath: keyPath] = newValue }
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Hosted, T>) -> T {
        instance[keyPath: keyPath]
    }
}

/// Usage: to create an autoreloading view, wrap your
/// view that you wish to see changes within `Inject.ViewHost`. For example,
/// If you are using a `TestView`, you would do the following:
/// `let myView = Inject.ViewHost(TestView())`
/// And within the parent view, you should add the view above.
@dynamicMemberLookup
public class _InjectableViewHost<Hosted: InjectViewType>: InjectViewType {
    public private(set) var instance: Hosted
    let constructor: () -> Hosted
    
    public init(_ constructor: @autoclosure @escaping () -> Hosted) {
        instance = constructor()
        self.constructor = constructor
        
        super.init(frame: .zero)
        addAsChild()
        onInjection { instance in
            instance.resetHosted()
        }
    }
    
    private func resetHosted() {
        instance.removeFromSuperview()
        
        instance = constructor()
        addAsChild()
    }
    
    private func addAsChild() {
        // add the real content as child
        addSubview(instance)
        
        instance.translatesAutoresizingMaskIntoConstraints = false
        [
            instance.topAnchor.constraint(equalTo: topAnchor),
            instance.leadingAnchor.constraint(equalTo: leadingAnchor),
            instance.bottomAnchor.constraint(equalTo: bottomAnchor),
            instance.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        .forEach { $0.isActive = true }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Hosted, T>) -> T {
        get { instance[keyPath: keyPath] }
        set { instance[keyPath: keyPath] = newValue }
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Hosted, T>) -> T {
        instance[keyPath: keyPath]
    }
}
#else

extension Inject {
    public static func ViewControllerHost(_ viewController: InjectViewControllerType) -> InjectViewControllerType {
        viewController
    }
    public static func ViewHost(_ view: InjectViewType) -> InjectViewType {
        view
    }
}

#endif

#if !os(watchOS)
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

public typealias ViewControllerHost = _InjectableViewControllerHost
public typealias ViewHost = _InjectableViewHost

/// Usage: to create an autoreloading view controller, wrap your
/// view controller that you wish to see changes within `ViewHost`. For example,
/// If you are using a `TestViewController`, you would do the following:
/// `let myView = ViewControllerHost(TestViewController())`
/// And within the parent view, you should add the view above.
@dynamicMemberLookup
open class _InjectableViewControllerHost<Hosted: InjectViewControllerType>: InjectViewControllerType {
    public private(set) var instance: Hosted
    let constructor: () -> Hosted
    /// Attaches a hook to be executed each time after a controller is reloaded.
    ///
    /// Usage:
    /// ```swift
    /// let myView = ViewControllerHost(TestViewController())
    /// myView.onInjectionHook = { hostedViewController in
    /// //any thing here will be executed each time the controller is reloaded
    /// // for example, you might want to re-assign the controller to your presenter
    ///     presenter.ui = hostedViewController
    /// }
    /// ```
    public var onInjectionHook: ((Hosted) -> Void)?
    
    public init(_ constructor: @autoclosure @escaping () -> Hosted) {
        instance = constructor()
        self.constructor = constructor
        
        super.init(nibName: nil, bundle: nil)
        self.enableInjection()
        
        addAsChild()
        onInjection { [weak self] instance in
            guard let self else { return }
            instance.resetHosted()
            self.onInjectionHook?(self.instance)
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
        tabBarItem = instance.tabBarItem
        definesPresentationContext = instance.definesPresentationContext
        modalPresentationStyle = instance.modalPresentationStyle
        #if !os(tvOS)
        navigationItem.title = instance.navigationItem.title
        navigationItem.titleView = instance.navigationItem.titleView
        navigationItem.backButtonTitle = instance.navigationItem.backButtonTitle
        navigationItem.backBarButtonItem = instance.navigationItem.backBarButtonItem
        navigationItem.leftBarButtonItems = instance.navigationItem.leftBarButtonItems
        navigationItem.rightBarButtonItems = instance.navigationItem.rightBarButtonItems
        navigationItem.largeTitleDisplayMode = instance.navigationItem.largeTitleDisplayMode
        navigationItem.searchController = instance.navigationItem.searchController
        navigationItem.hidesSearchBarWhenScrolling = instance.navigationItem.hidesSearchBarWhenScrolling
        toolbarItems = instance.toolbarItems
        hidesBottomBarWhenPushed = instance.hidesBottomBarWhenPushed
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
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
#if canImport(UIKit) && os(iOS)
    override open var childForStatusBarStyle: InjectViewControllerType? {
        instance
    }
#endif

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Hosted, T>) -> T {
        get { instance[keyPath: keyPath] }
        set { instance[keyPath: keyPath] = newValue }
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Hosted, T>) -> T {
        instance[keyPath: keyPath]
    }
}

/// Usage: to create an autoreloading view, wrap your
/// view that you wish to see changes within `ViewHost`. For example,
/// If you are using a `TestView`, you would do the following:
/// `let myView = ViewHost(TestView())`
/// And within the parent view, you should add the view above.
@dynamicMemberLookup
public class _InjectableViewHost<Hosted: InjectViewType>: InjectViewType {
    public private(set) var instance: Hosted
    let constructor: () -> Hosted
    
    public init(_ constructor: @autoclosure @escaping () -> Hosted) {
        instance = constructor()
        self.constructor = constructor
        
        super.init(frame: .zero)
        self.enableInjection()
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

extension InjectConfiguration {
    public static func ViewControllerHost<Hosted: InjectViewControllerType>(_ viewController: Hosted) -> Hosted {
        viewController
    }
    public static func ViewHost<Hosted: InjectViewType>(_ view: Hosted) -> Hosted {
        view
    }
}

#endif
#endif

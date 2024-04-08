# Inject
Hot reloading workflow helper that enables you to save hours of time each week, regardless if you are using `UIKit`, `AppKit` or `SwiftUI`.

[**If you'd like to support my work and improve your engineering workflows, check out my SwiftyStack course**](https://www.swiftystack.com/)

**TLDR: A single line of code** change allows you to live code `UIKit` screen:


https://user-images.githubusercontent.com/26660989/161756368-b150bc25-b66f-4822-86ee-2e4aed713932.mp4



[Read detailed article about this](https://merowing.info/2022/04/hot-reloading-in-swift/)

The heavy lifting is done by the amazing [InjectionIII](https://github.com/johnno1962/InjectionIII). This library is just a thin wrapper to provide the best developer experience possible while requiring minimum effort. 

I've been using it for years.

## What is hot reloading?
Hot reloading is a technique allowing you to get rid of compiling your whole application and avoiding deploy/restart cycles as much as possible, all while allowing you to edit your running application code and see changes reflected as close as possible to real-time.

This makes you significantly more productive by reducing the time you spend waiting for apps to rebuild, restart, re-navigate to the previous location where you were in the app itself, re-produce the data you need.

This can save you literal hours off development time, **each day**! 

## Does it add manual overhead to my workflows?
Once you configured your project initially, it's practically free.

You don’t need to add conditional compilation or remove `Inject` code from your applications for production, it's already designed to behave as no-op inlined code that will get stripped by LLVM in non-debug builds. 

Which means that you can enable it once per view and keep using it for years to come.

# Integration
### Initial project setup

To integrate `Inject` just add it as SPM dependency:

### via Xcode

Open your project, click on File → Swift Packages → Add Package Dependency…, enter the repository url (`https://github.com/krzysztofzablocki/Inject.git`) and add the package product to your app target.

### via SPM package.swift

```swift
dependencies: [
    .package(
      url: "https://github.com/krzysztofzablocki/Inject.git",
      from: "1.2.4"
    )
]
```

### via Cocoapods Podfile

```ruby
pod 'InjectHotReload'
```

### Individual Developer setup (once per machine)
If anyone in your project wants to use injection, they only need to:

- You must add "-Xlinker -interposable" (without the double quotes and on separate lines) to the "Other Linker Flags" of all targets in your project for the Debug configuration (qualified by the simulator SDK to avoid complications with bitcode), refer to [InjectionForXcode documentation](https://github.com/johnno1962/InjectionIII#limitationsfaq) if you run into any issues
-  Download newest version of Xcode Injection from it's [GitHub Page](https://github.com/johnno1962/InjectionIII/releases)
  - Unpack it and place under `/Applications`
- Make sure that the Xcode version you are using to compile our projects is under the default location: `/Applications/Xcode.app`
- Run the injection application
- Select open project / open recent from it's menu and pick the right workspace file you are using

 After choosing the project in Injection app, launch the app
- If everything is configured correctly you should see similar log in the console:

```bash
💉 InjectionIII connected /Users/merowing/work/SourceryPro/App.xcworkspace
💉 Watching files under /Users/merowing/work/SourceryPro
```

## Workflow integration
You can either add `import Inject` in individual files in your project or use 
`@_exported import Inject` in your project target to have it automatically available in all its files.

#### **SwiftUI**
Just 2 steps to enable injection in your `SwiftUI` Views

- call `.enableInjection()` at the end of your body definition
- add `@ObserveInjection var inject` to your view struct

> *Remember you **don't need** to remove this code when you are done, it's NO-OP in production builds.*

If you want to see your changes in action, you can enable an optional `Animation` variable on `InjectConfiguration.animation` that will be used when ever new source code is injected into your application.

```swift
InjectConfiguration.animation = .interactiveSpring()
```

Using `Inject` is demoed in this [example app](https://github.com/MarcoEidinger/InjectSwiftUIExample) 

####  **UIKit / AppKit**
For standard imperative UI frameworks we need a way to clean-up state between code injection phases. 

I create the concept of **Hosts** that work really well in that context, there are 2:

- `ViewControllerHost`
- `ViewHost`

How do we integrate this? We wrap the class we want to iterate on at the parent level, so we don’t modify the class we want to be injecting but we modify the parent callsite.

Eg. If you have a `SplitViewController` that creates `PaneA` and `PaneB `, and you want to iterate on layout/logic code in `PaneA`, you modify the callsite in `SplitViewController`:

```swift
paneA = Inject.ViewHost(
  PaneAView(whatever: arguments, you: want)
)
```

That is all the changes you need to do, your app now allows you to change anything in `PaneAView` except for its initialiser API and the changes will be almost immediately reflected in your App.

Make sure to call initializer inside `Inject.ViewControllerHost(...)` or `Inject.ViewHost(...)`. Inject relies on `@autoclosure` to reload views when hot-reload happens. Example:
```swift
// WRONG
let viewController = YourViewController()
rootViewController.pushViewController(Inject.ViewControllerHost(viewController), animated: true)

// CORRECT
let viewController = Inject.ViewControllerHost(YourViewController())
rootViewController.pushViewController(viewController, animated: true)
```
> *Remember you **don't need** to remove this code when you are done, it's NO-OP in production builds.*


####  **Injection Hook for UIKit**
depending on the architecture used in your UIKit App, you might want to attach a hook to be executed each time a view controller is reloaded.

Eg. you might want to bind the `UIViewController` to the presenter each-time there's a reload, to achieve this you can use `onInjectionHook`
   Example:

```swift
myView.onInjectionHook = { hostedViewController in
//any thing here will be executed each time the controller is reloaded
// for example, you might want to re-assign the controller to your presenter
presenter.ui = hostedViewController
}
```

#### iOS 12
You need to add -weak_framework SwiftUI to Other Linker Flags for iOS 12 to work.

#### The Composable Architecture

If like myself you love [PointFree](https://pointfree.co/) Composable Architecture, you’d probably want to inject reducer code, this isn’t possible in vanilla TCA because reducer code is a free function which isn’t as straightforward to replace with injection, but [our fork](https://github.com/thebrowsercompany/swift-composable-architecture) at [The Browser Company](https://thebrowser.company/) supports it.

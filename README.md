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

- You must add "-Xlinker -interposable" (without the double quotes and on separate lines) to the "Other Linker Flags" of all targets in your project for the **Debug** configuration (qualified by the simulator SDK to avoid complications with bitcode), refer to [InjectionForXcode documentation](https://github.com/johnno1962/InjectionIII#limitationsfaq) if you run into any issues
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

## (Optional) Automatic Injection Script

> **WARNING:** This script automatically modifies your Swift source code. It's provided as a convenience but use it with caution!  Review the changes it makes carefully. It might not be suitable for all projects or coding styles. Consider using Xcode code snippets for more manual control.

To automatically add `import Inject`, `@ObserveInjection var inject`, and `.enableInjection()` to your SwiftUI views, you can add the following script as a "Run Script" build phase in your Xcode project:

```sh
#!/bin/bash

# Function to modify a single Swift file
modify_swift_file() {
    local filepath="$1"
    local filename=$(basename "$filepath")
    local tempfile="$filepath.tmp"

    # Check if the file should be processed
    if [[ $(grep -c ": View {" "$filepath") -eq 0 ]]; then
        echo "Skipping: $filename (No ': View {' found)"
        return
    fi

    # Create a temporary file for modifications
    cp "$filepath" "$tempfile"

    # 1. Add import Inject if needed
    if ! grep -q "import Inject" "$tempfile"; then
        sed -i '' -e '/^import SwiftUI/a\
import Inject' "$tempfile"
    fi

    # 2. Add @ObserveInjection var inject if needed
    if ! grep -q "@ObserveInjection var inject" "$tempfile"; then
        sed -i '' -e '/struct.*: View {/a\
    @ObserveInjection var inject' "$tempfile"
    fi

    # 3. Add .enableInjection() just before the closing brace of the body
    # Find the start of var body: some View {
    local body_start_line=$(grep -n "var body: some View {" "$tempfile" | cut -d ':' -f 1)

    if [[ -n "$body_start_line" ]]; then
        # Get the line number of the closing brace of the body
        local body_end_line=$(awk -v start="$body_start_line" '
            NR == start { count = 1 }
            NR > start {
                if ($0 ~ /{/) count++
                if ($0 ~ /}/) {
                    count--
                    if (count == 0) {
                        print NR
                        exit
                    }
                }
            }
        ' "$tempfile")

        if [[ -n "$body_end_line" ]]; then
            # Check if .enableInjection() is already present
            if ! grep -q ".enableInjection()" "$tempfile"; then
                # Insert .enableInjection() before the closing brace of the body
                sed -i '' -e "${body_end_line}i\\
        .enableInjection()" "$tempfile"
            fi
        fi
    fi

    # Check if modifications were made and overwrite the original file
    if ! cmp -s "$filepath" "$tempfile"; then
        mv "$tempfile" "$filepath"
        echo "Modified: $filename"
    else
        echo "No changes for: $filename"
    fi

    rm -f "$tempfile"
}

# Main script
find "$SRCROOT" -name "*.swift" -print0 | while IFS= read -r -d $'\0' filepath; do
    modify_swift_file "$filepath"
done

echo "Inject modification script completed."
```

#### iOS 12
You need to add -weak_framework SwiftUI to Other Linker Flags for iOS 12 to work.

#### The Composable Architecture

Since the introduction of ReducerProtocol you can use Inject with TCA without support code.

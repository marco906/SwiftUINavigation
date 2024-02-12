# SwiftUINavigation

## Overview
This is an open-source library to use with SwiftUI. It allows you perform navigation actions easily.

- Define your navigation routes and make your view conform to NavigationScreen for easy routing
- Stack actions: push, pop, popToRoot
- Modal actions: push sheets, fullScreens, popovers and alerts

## Requirements
- iOS 16.0
- macOS 13.0
- WatchOS 9.0

## Installation
Use Swift Package Manager to add SwiftUINavigation to your XCode project.
1. In Xcode, select File > Add Packages...
2. Enter the package URL for this repository [SwiftUINavigation](https://github.com/marco906/SwiftUINavigation).

## Usage
You can find the full demo example that you can build and run in the folder SwiftUINavigationDemo.

### Define your routes
- Create an enum for your app routes and make it conform to the `Routable` protocol.
- Define the SwiftUI Views that the routes should navigate to.

```swift
import SwiftUINavigation
import SwiftUI

enum AppRoute: Routable {
    case demo(_ number: Int)
    
    var id: String {
        switch self {
        case let .demo(number): "demo_\(number)"
        }
    }
    
    @MainActor
    @ViewBuilder
    var view: some View {
        switch self {
        case let .demo(number): DetailView(number: number)
        }
    }
}

```

### Configure your root view to use Navigators
- Add a `@StateObject` for stack navigator and a modal navigator in your root view that defines the NavigationStack
- Add another navigator if you need a sub navigator to manage the modal navigation path separatly
- Set the path for the root NavigationStack to `$navigator.path`
- Add modal destinations for sheets, fullscreens, alerts, etc. as needed and let `modalNavigator` handle the presentation.
- Pass the navigators as environment objects to the child views

```swift
import SwiftUINavigation
import SwiftUI

struct ContentView: View {
    @StateObject var navigator = Navigator()
    @StateObject var modalNavigator = ModalNavigator()
    @StateObject var subNavigator = Navigator()
    
    var body: some View {
        NavigationStack(path: $navigator.path) {
            DetailView(number: 1)
        }
        .environmentObject(navigator)
        .environmentObject(modalNavigator)
        .sheet(item: $modalNavigator.sheetDestination) { route in
            modalDestination(route)
        }
        .fullScreenCover(item: $modalNavigator.fullScreenDestination) { route in
            modalDestination(route)
        }
        .alert(isPresented: $modalNavigator.showAlert, details: modalNavigator.alertDetails)
    }
    
    func modalDestination(_ route: Route) -> some View {
        NavigationStack(path: $subNavigator.path) {
            if let r = route.destination as? AppRoute {
                r.view
            }
        }
        .environmentObject(subNavigator)
        .environmentObject(modalNavigator)
    }
}

```

### Implement NavigationScreen
- In the views where you want to perform navigation actions, implement the `NavigationScreen` protocol
- Add the required navigators as `@EnvironmentObject` variables
- Add the navigationDestination for your routes


```swift
import SwiftUINavigation
import SwiftUI

struct DetailView: View, NavigationScreen {
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject var modalNavigator: ModalNavigator
    
    var body: some View {
		....
        .navigationDestination(for: AppRoute.self) { route in
            route.view
        }
    }
}

```

### Perform navigation action
- Inside a View that conforms to `NavigationScreen` you can perform navigation actions as follows

push, pop, popToRoot

```swift
Button("Root") {
	popToRoot()
}
Button("Previous") {
	pop()
}
Button("Next") {
	push(AppRoute.demo(1))
}

```

push sheets, fullscreens, popOvers

```swift
Button("Sheet") {
	pushSheet(AppRoute.demo(1))
}
Button("Fullscreen") {
	pushFullscreen(AppRoute.demo(1))
}
Button("Popover") {
	pushPopover(AppRoute.demo(1))
}

```

alerts

```swift
Button("Alert") {
	let details = AlertDetails(
		title: "Alert",
		message: "This is an alert message",
		onConfirm: {},
		confirmationtitle: "Got it!"
	)
	pushAlert(details)
}

```
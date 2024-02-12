//
//  SwiftUINavigationDemoApp.swift
//  SwiftUINavigationDemo
//
//  Created by Marco Wenzel on 12.02.24.
//

import SwiftUI
import SwiftUINavigation

@main
struct SwiftUINavigationDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

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

#Preview {
    ContentView()
}

struct DetailView: View, NavigationScreen {
    @Environment(\.isPresented) var isPresented
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject var modalNavigator: ModalNavigator
    
    init(number: Int) {
        self.number = number
    }
    
    var number: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Navigate")
            HStack{
                Button("Root") {
                    popToRoot()
                }
                Button("Previous") {
                    pop()
                }
                Button("Next") {
                    push(AppRoute.demo(number + 1))
                }

            }
            Text("Modals")
            HStack{
                if isPresented {
                    Button("Close") {
                        closeAllModals()
                        popToRoot()
                    }
                } else {
                    Button("Sheet") {
                        pushSheet(AppRoute.demo(1))
                    }
                    Button("Fullscreen") {
                        pushFullscreen(AppRoute.demo(1))
                    }
                    Button("Alert") {
                        let details = AlertDetails(
                            title: "Alert",
                            message: "This is an alert message",
                            onConfirm: {},
                            confirmationtitle: "Got it!"
                        )
                        pushAlert(details)
                    }
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .navigationTitle(isPresented ? "Sheet \(number)" : "Page \(number)")
        .navigationDestination(for: AppRoute.self) { route in
            route.view
        }
    }
}

//
//  Navigator.swift
//  
//
//  Created by Marco Wenzel on 12.02.24.
//

import Foundation
import SwiftUI

// MARK: - Routes

public protocol Routable: Identifiable, Hashable {
    var id: String { get }
}

public struct Route: Identifiable, Hashable {
    public static func == (lhs: Route, rhs: Route) -> Bool {
        rhs.destination.id == lhs.destination.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(destination.id)
    }
    
    public var destination: any Routable
    public var id: String { destination.id}
}

// MARK: - Navigators

@MainActor
final public class Navigator: ObservableObject {
    @Published public var path = NavigationPath()
    
    public init() {}
    
    public func push(_ destination: any Hashable) {
        path.append(destination)
    }
    
    public func pop() {
        if path.isEmpty { return }
        path.removeLast()
    }
    
    public func popToRooot() {
        path.removeLast(path.count)
    }
}

@MainActor
final public class ModalNavigator: ObservableObject {
    @Published public var sheetDestination: Route?
    @Published public var fullScreenDestination: Route?
    @Published public var popoverDestination: Route?
    @Published public var alertDetails: AlertDetails?
    @Published public var showAlert = false
    
    public init() {}
    
    public func pushSheet(_ destination: Route) {
        fullScreenDestination = nil
        sheetDestination = destination
    }
    
    public func pushFullscreen(_ destination: Route) {
        sheetDestination = nil
        fullScreenDestination = destination
    }
    
    public func pushPopOver(_ destination: Route) {
        popoverDestination = destination
    }
    
    public func pushAlert(_ details: AlertDetails) {
        alertDetails = details
        showAlert = true
    }
}

public protocol NavigationScreen {
    var modalNavigator: ModalNavigator { get }
    var navigator: Navigator { get }
}

public extension NavigationScreen {
    @MainActor
    func push(_ destination: any Routable) {
        navigator.push(destination)
    }
    
    @MainActor
    func pushAlert(_ destination: AlertDetails) {
        modalNavigator.pushAlert(destination)
    }
    
    @MainActor
    func pushSheet(_ destination: any Routable) {
        modalNavigator.pushSheet(Route(destination: destination))
    }
    
    @MainActor
    func pushPopover(_ destination: any Routable) {
        modalNavigator.pushPopOver(Route(destination: destination))
    }
    
    @MainActor
    func pushFullscreen(_ destination: any Routable) {
        modalNavigator.pushFullscreen(Route(destination: destination))
    }
    
    @MainActor
    func pop() {
        navigator.pop()
    }
    
    @MainActor
    func popToRoot() {
        navigator.popToRooot()
    }
    
    @MainActor
    func closeAllModals() {
        modalNavigator.sheetDestination = nil
        modalNavigator.fullScreenDestination = nil
        modalNavigator.showAlert = false
    }
}

// MARK: - Alerts

public struct AlertDetails: Hashable {
    public var title: LocalizedStringKey?
    public var message: LocalizedStringKey?
    public var onConfirm: (() -> Void)?
    public var confirmationtitle: LocalizedStringKey?
    public var destructive: Bool
    public var cancel: Bool
    
    public init(title: LocalizedStringKey? = nil, message: LocalizedStringKey? = nil, onConfirm: ( () -> Void)? = nil, confirmationtitle: LocalizedStringKey? = nil, destructive: Bool = false, cancel: Bool = true) {
        self.title = title
        self.message = message
        self.onConfirm = onConfirm
        self.confirmationtitle = confirmationtitle
        self.destructive = destructive
        self.cancel = cancel
    }
    
    public static func == (lhs: AlertDetails, rhs: AlertDetails) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: title))
        hasher.combine(String(describing: message))
    }
}

@MainActor
public extension View {
    func alert(isPresented: Binding<Bool>, details: AlertDetails?) -> some View {
        alert(
            details?.title ?? "",
            isPresented: isPresented,
            presenting: details
        ) { alertDetails in
            if let details = details, let onConfirm = details.onConfirm {
                if details.cancel {
                    Button("Cancel", role: .cancel, action: {})
                }
                Button(
                    details.confirmationtitle ?? "Confirm",
                    role: details.destructive ? .destructive : nil,
                    action: onConfirm)
            }
        } message: { alertDetails in
            if let msg = alertDetails.message {
                Text(msg)
            }
        }
    }
}

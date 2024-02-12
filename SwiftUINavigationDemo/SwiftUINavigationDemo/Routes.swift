//
//  Routes.swift
//  SwiftUINavigationDemo
//
//  Created by Marco Wenzel on 12.02.24.
//

import Foundation
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

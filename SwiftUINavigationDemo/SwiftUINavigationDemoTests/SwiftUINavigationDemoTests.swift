//
//  SwiftUINavigationDemoTests.swift
//  SwiftUINavigationDemoTests
//
//  Created by Marco Wenzel on 12.02.24.
//

import XCTest
import SwiftUINavigation

final class SwiftUINavigationDemoTests: XCTestCase, NavigationScreen {
    @MainActor var modalNavigator = SwiftUINavigation.ModalNavigator()
    @MainActor var navigator = SwiftUINavigation.Navigator()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor 
    func testPush() throws {
        XCTAssertTrue(navigator.path.isEmpty, "Path should be empty at init")
        
        push(AppRoute.demo(1))
        XCTAssertTrue(navigator.path.count == 1, "Failed to push route")
        
        push(AppRoute.demo(2))
        XCTAssertTrue(navigator.path.count == 2, "Failed to push route")
    }
    
    @MainActor
    func testPop() throws {
        popToRoot()
        XCTAssertTrue(navigator.path.isEmpty, "Path should be empty")
        
        pop()
        XCTAssertTrue(navigator.path.isEmpty, "Path should be empty")
        
        push(AppRoute.demo(1))
        push(AppRoute.demo(2))
        pop()
        XCTAssertTrue(navigator.path.count == 1, "failed to pop")
        
        push(AppRoute.demo(1))
        push(AppRoute.demo(2))
        push(AppRoute.demo(3))
        popToRoot()
        XCTAssertTrue(navigator.path.isEmpty, "failed to pop to root")
    }
}

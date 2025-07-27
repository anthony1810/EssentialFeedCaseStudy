//
//  SceneDelegateTests.swift
//  EssentialApp
//
//  Created by Anthony on 23/7/25.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {
    func test_configuresWindow_setWindowAsKeyAndVisible() {
        let sut = SceneDelegate()
        let windowSpy = WindowSpy()
        sut.window = windowSpy
        
        sut.configureWindow()
        
        XCTAssertEqual(windowSpy.makeKeyAndVisibleCalledCount, 1, "Guarantee that SceneDelegate setup window correctly")
    }
    
    func test_configuresWindow_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topVC = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expect a navigation controller as root, got \(String(describing: rootNavigation)) instead")
        XCTAssertTrue(topVC is FeedViewController, "Expect a FeedViewController as top view controller, got \(String(describing: topVC)) instead")
    }
    
    // MARK: - Helpers
    private class WindowSpy: UIWindow {
        var makeKeyAndVisibleCalledCount = 0
        
        override func makeKeyAndVisible() {
            makeKeyAndVisibleCalledCount += 1
        }
    }
}

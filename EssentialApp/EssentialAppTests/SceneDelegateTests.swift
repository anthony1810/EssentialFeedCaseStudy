//
//  SceneDelegateTests.swift
//  EssentialApp
//
//  Created by Anthony on 27/11/24.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {
    
    func test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topVC = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expect UINavigationController, got \(String(describing: root))")
        XCTAssertTrue(topVC is ListViewController, "expect FeedViewController, got \(String(describing: topVC))")
    }
    
    func test_configuresRootViewController_rendersCustomWindowAsKeyAnDVisible() {
        let window = WindowSpy()
        let sut = SceneDelegate()
        
        sut.window = window
        
        sut.configureWindow()
        
        XCTAssertEqual(window.makeKeyAndVisibleCount, 1, "Expect window to be to be key window")
    }
}

private class WindowSpy: UIWindow {
    var makeKeyAndVisibleCount = 0
    
    override func makeKeyAndVisible() {
        makeKeyAndVisibleCount += 1
    }
}

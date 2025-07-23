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
    func test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topVC = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expect a navigation controller as root, got \(String(describing: rootNavigation)) instead")
        XCTAssertTrue(topVC is FeedViewController, "Expect a FeedViewController as top view controller, got \(String(describing: topVC)) instead")
    }
}

//
//  SceneDelegateTests.swift
//  EssentialApp
//
//  Created by Anthony on 27/11/24.
//

import UIKit
import Foundation
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
        
        XCTAssertNil(rootNavigation, "Expect UINavigationController, got \(String(describing: root))")
        XCTAssertTrue(topVC is FeedViewController, "expect FeedViewController, got \(String(describing: topVC))")
    }
}

//
//  EssentialFeediOSTests.swift
//  EssentialFeediOSTests
//
//  Created by Anthony on 18/2/25.
//

import XCTest
@testable import EssentialFeediOS

final class FeedViewController: UIViewController {
    var loader: EssentialFeediOSTests.LoaderSpy?
    
    convenience init(loader: EssentialFeediOSTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load()
    }
}

final class EssentialFeediOSTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCalls, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let feedViewController = FeedViewController(loader: loader)
        feedViewController.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCalls, 1)
    }
    
    // MARK: - Helper
    class LoaderSpy {
        var loadCalls = 0
        
        func load() {
            loadCalls += 1
        }
    }
}

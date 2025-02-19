//
//  EssentialFeediOSTests.swift
//  EssentialFeediOSTests
//
//  Created by Anthony on 18/2/25.
//

import XCTest
import EssentialFeediOS
import EssentialFeed

final class FeedViewController: UIViewController {
    var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load { _ in }
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
    class LoaderSpy: FeedLoader {
        var loadCalls = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCalls += 1
            
        }
    }
}

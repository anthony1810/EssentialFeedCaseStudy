//
//  FeedViewControllerTests.swift
//  EssentialFeed
//
//  Created by Anthony on 26/10/24.
//

import XCTest

final class FeedViewController {
    let loader: FeedViewControllerTests.LoaderSpy
    
    init(loader: FeedViewControllerTests.LoaderSpy) {
        self.loader = loader
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() throws {
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    
}

extension FeedViewControllerTests {
    class LoaderSpy {
        var loadCallCount: Int = 0
        
        func load(completion: @escaping (Result<Void, Error>) -> Void) {
            loadCallCount += 1
        }
    }
}

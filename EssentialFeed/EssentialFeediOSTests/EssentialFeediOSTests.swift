//
//  EssentialFeediOSTests.swift
//  EssentialFeediOSTests
//
//  Created by Anthony on 18/2/25.
//

import XCTest
@testable import EssentialFeediOS

final class FeedViewController {
    let loader: EssentialFeediOSTests.LoaderSpy
    
    init(loader: EssentialFeediOSTests.LoaderSpy) {
        self.loader = loader
    }
}

final class EssentialFeediOSTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCalls, 0)
    }
    
    // MARK: - Helper
    class LoaderSpy {
        var loadCalls = 0
    }
}

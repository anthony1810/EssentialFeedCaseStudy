//
//  FeedViewControllerTests.swift
//  EssentialFeed
//
//  Created by Anthony on 26/10/24.
//

import XCTest
import UIKit

final class FeedViewController: UIViewController {
    private var loader: FeedViewControllerTests.LoaderSpy
    
    init(loader: FeedViewControllerTests.LoaderSpy) {
        self.loader = loader
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader.load(completion: { _ in })
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() throws {
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() throws {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
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

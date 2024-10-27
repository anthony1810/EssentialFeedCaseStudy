//
//  FeedViewControllerTests.swift
//  EssentialFeed
//
//  Created by Anthony on 26/10/24.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    
    func test_userInitiatedRefresh_loadFeedCorrectAsExepcted() throws {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCompletionResult.count, 0)
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        XCTAssertEqual(loader.loadCompletionResult.count, 1)
        
        sut.userInitiatedRefresh()
        XCTAssertEqual(loader.loadCompletionResult.count, 2)
        
        sut.userInitiatedRefresh()
        XCTAssertEqual(loader.loadCompletionResult.count, 3)
    }
    
    func test_loadFeeds_showHideIndicatorCorrectly() throws {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        XCTAssertEqual(sut.isShowingLoadingIndicator(), true)
        
        loader.completeFeedLoadingSuccess(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator(), false)
        
        sut.userInitiatedRefresh()
        XCTAssertEqual(sut.isShowingLoadingIndicator(), true)
        
        loader.completeFeedLoadingSuccess(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator(), false)
    }
    
}

extension FeedViewController {
    func userInitiatedRefresh() {
        self.refreshControl?.simulatePullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        self.refreshControl?.isRefreshing ?? false
    }
}

extension FeedViewControllerTests {
    
    class LoaderSpy: FeedLoader {
        
        var loadCompletionResult = [(FeedLoader.Result) -> Void]()
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCompletionResult.append(completion)
        }
        
        func completeFeedLoadingSuccess(at index: Int = 0) {
            loadCompletionResult[index](.success([]))
        }
    }
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
}

private extension FeedViewController {
    
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            })
        }
        
        refreshControl = fake
    }
}

class FakeRefreshControl: UIRefreshControl {
    
    var _isRefreshing: Bool = false
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}

extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

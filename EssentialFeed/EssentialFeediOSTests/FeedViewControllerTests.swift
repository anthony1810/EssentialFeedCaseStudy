//
//  FeedViewControllerTests.swift
//  EssentialFeed
//
//  Created by Anthony on 26/10/24.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UITableViewController {
    private var loader: FeedLoader
    
    init(loader: FeedViewControllerTests.LoaderSpy) {
        self.loader = loader
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(loadFeeds), for: .valueChanged)
        loadFeeds()
    }
    
    @objc
    func loadFeeds() {
        self.refreshControl?.beginRefreshing()
        loader.load(completion: { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        })
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() throws {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCompletionResult.count, 0)
    }
    
    func test_viewDidLoad_loadsFeed() throws {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCompletionResult.count, 1)
    }
    
    func test_userInitiatedRefresh_loadsFeed() throws {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        sut.userInitiatedRefresh()
        
        XCTAssertEqual(loader.loadCompletionResult.count, 2)
        
        sut.userInitiatedRefresh()
        
        XCTAssertEqual(loader.loadCompletionResult.count, 3)
    }
    
    func test_viewDidLoad_showLoadingIndicator() throws {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator(), true)
    }
    
    func test_viewDidLoad_hideLoadingIndicatorOnLoadCompletion() throws {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingSuccess()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator(), false)
    }
    
    func test_userInitatedRefresh_showLoadingIndicator() throws {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        sut.userInitiatedRefresh()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator(), true)
    }
    
    func test_userInitatedRefresh_hideLoadingIndicatorWhenFinish() throws {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        sut.userInitiatedRefresh()
        
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
        
        func completeFeedLoadingSuccess() {
            loadCompletionResult[0](.success([]))
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

extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

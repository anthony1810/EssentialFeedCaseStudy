//
//  EssentialFeediOSTests.swift
//  EssentialFeediOSTests
//
//  Created by Anthony on 18/2/25.
//

import XCTest
import EssentialFeediOS
import EssentialFeed

final class EssentialFeediOSTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCalls, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (feedViewController, loader) = makeSUT()
        
        feedViewController.simulateAppearance()
        
        XCTAssertEqual(loader.loadCalls, 1)
    }
    
    func test_pullToRefresh_loadsFeed() {
        let (feedViewController, loader) = makeSUT()
        feedViewController.simulateAppearance()
        
        feedViewController.userInitiateFeedReload()
        XCTAssertEqual(loader.loadCalls, 2)
        
        feedViewController.userInitiateFeedReload()
        XCTAssertEqual(loader.loadCalls, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (feedViewController, _) = makeSUT()
        
        feedViewController.simulateAppearance()
        
        XCTAssertEqual(feedViewController.isLoadingIndicatorVisible(), true)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorAfterLoading() {
        let (feedViewController, loader) = makeSUT()
        
        feedViewController.simulateAppearance()
        loader.completeLoadingFeed()
        XCTAssertEqual(feedViewController.isLoadingIndicatorVisible(), false)
    }
    
    func test_pullToRefresh_showsLoadingIndicator() {
        let (feedViewController, _) = makeSUT()
        
        feedViewController.simulateAppearance()
        feedViewController.userInitiateFeedReload()
        
        XCTAssertEqual(feedViewController.isLoadingIndicatorVisible(), true)
    }
    
    func test_pullToRefresh_hidesLoadingIndicatorAfterLoading() {
        let (feedViewController, loader) = makeSUT()
        
        feedViewController.simulateAppearance()
        feedViewController.userInitiateFeedReload()
        loader.completeLoadingFeed()
        
        XCTAssertEqual(feedViewController.isLoadingIndicatorVisible(), false)
    }
    
    // MARK: - Helper
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let feedViewController = FeedViewController(loader: loader)
        
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(feedViewController, file: file, line: line)
        
        return (feedViewController, loader)
    }
   
    class LoaderSpy: FeedLoader {
        var loadCalls: Int {
            completions.count
        }
        
        var completions: [(FeedLoader.Result) -> Void] = []
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeLoadingFeed() {
            completions[0](.success([]))
        }
    }
}

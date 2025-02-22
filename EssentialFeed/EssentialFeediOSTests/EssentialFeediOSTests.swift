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
    
    func test_userInitiatedFeedReload_loadsFeed() {
        let (feedViewController, loader) = makeSUT()
        
        feedViewController.simulateAppearance()
        XCTAssertEqual(loader.loadCalls, 1)
        
        feedViewController.userInitiateFeedReload()
        XCTAssertEqual(loader.loadCalls, 2)
        
        feedViewController.userInitiateFeedReload()
        XCTAssertEqual(loader.loadCalls, 3)
    }
    
    func test_userIninitedFeedReload_showsLoadingIndicator() {
        let (feedViewController, loader) = makeSUT()
        
        feedViewController.simulateAppearance()
        XCTAssertEqual(feedViewController.isLoadingIndicatorVisible(), true)

        loader.completeLoadingFeed()
        XCTAssertEqual(feedViewController.isLoadingIndicatorVisible(), false)

        feedViewController.userInitiateFeedReload()
        XCTAssertEqual(feedViewController.isLoadingIndicatorVisible(), true)

        loader.completeLoadingFeed()
        XCTAssertEqual(feedViewController.isLoadingIndicatorVisible(), false)
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeedItems() {
        let feedImage0 = makeFeedImage(description: "a description", location: "a location")
        let feedImage1 = makeFeedImage(description: "a description", location: nil)
        let feedImage2 = makeFeedImage(description: nil, location: "a location")
        let feedImage3 = makeFeedImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [])
        
        loader.completeLoadingFeed([feedImage0], at: 0)
        assertThat(sut, isRendering: [feedImage0])
        
        sut.userInitiateFeedReload()
        loader.completeLoadingFeed([feedImage1, feedImage2, feedImage3], at: 1)
        assertThat(sut, isRendering: [feedImage1, feedImage2, feedImage3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderedItems() {
        let feedImage0 = makeFeedImage(description: "a description", location: "a location")
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        loader.completeLoadingFeed([feedImage0])
        assertThat(sut, isRendering: [feedImage0])
        
        sut.userInitiateFeedReload()
        loader.completeLoadingFeedWithError(at: 1)
        assertThat(sut, isRendering: [feedImage0])
    }
        
    // MARK: - Helper
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let feedViewController = FeedViewController(loader: loader)
        
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(feedViewController, file: file, line: line)
        
        return (feedViewController, loader)
    }
    
    func makeFeedImage(id: UUID = UUID(), description: String?, location: String?, url: URL = URL(string: "https://anyUrl.com")!) -> FeedImage {
        return FeedImage(
            id: id,
            description: description,
            location: location,
            imageURL: url
        )
    }
    
    func assertThat(
        _ sut: FeedViewController,
        isRendering feeds: [FeedImage],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedFeeds() == feeds.count else {
            XCTFail(
                "Expected \(feeds.count) rendered feeds but \(sut.numberOfRenderedFeeds()) were rendered.",
                file: file,
                line: line
            )
            return
        }
        
        feeds.enumerated().forEach { index, feed in
            assertThat(sut, isRendering: feed, at: index, file: file, line: line)
        }
    }
    
    func assertThat(
        _ sut: FeedViewController,
        isRendering feed: FeedImage,
        at index: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let cell = sut.feedImageView(at: index) else {
            XCTFail("Missing feed cell at index \(index)", file: file, line: line)
            return
        }
        
        let isLocationHidden = feed.location == nil
        
        XCTAssertEqual(
            feed.location,
            cell.locationText,
            "assert that feed location \(String(describing: feed.location)) matches cell location \(String(describing: cell.locationText)) at index = \(index)",
            file: file,
            line: line
        )
        
        XCTAssertEqual(
            feed.description,
            cell.descriptionText,
            "assert that feed description \(String(describing: feed.description)) matches cell description \(String(describing: cell.description)) at index = \(index)",
            file: file,
            line: line)
        
        XCTAssertEqual(
            isLocationHidden,
            !cell.isShowingLocation,
            "assert that feed isLocationHidden \(String(describing: isLocationHidden)) matches cell isShowingLocation \(String(describing: cell.isShowingLocation)) at index = \(index)",
            file: file,
            line: line)
    }
   
    class LoaderSpy: FeedLoader {
        var loadCalls: Int {
            completions.count
        }
        
        var completions: [(FeedLoader.Result) -> Void] = []
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeLoadingFeed(_ feeds: [FeedImage] = [], at index: Int = 0) {
            completions[index](.success(feeds))
        }
        
        func completeLoadingFeedWithError(_ error: Error = NSError(domain: "", code: 0, userInfo: nil), at index: Int) {
            completions[index](.failure(error))
        }
    }
}

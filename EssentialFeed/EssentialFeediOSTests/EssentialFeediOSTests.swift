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
        
        XCTAssertEqual(loader.loadFeedCalls, 0)
    }
    
    func test_userInitiatedFeedReload_loadsFeed() {
        let (feedViewController, loader) = makeSUT()
        
        feedViewController.simulateAppearance()
        XCTAssertEqual(loader.loadFeedCalls, 1)
        
        feedViewController.userInitiateFeedReload()
        XCTAssertEqual(loader.loadFeedCalls, 2)
        
        feedViewController.userInitiateFeedReload()
        XCTAssertEqual(loader.loadFeedCalls, 3)
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
        
        feedViewController.userInitiateFeedReload()
        XCTAssertEqual(feedViewController.isLoadingIndicatorVisible(), true)
        
        loader.completeLoadingFeedWithError()
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
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let feedImage0 = makeFeedImage(description: "a description", location: "a location")
        let feedImage1 = makeFeedImage(description: "a description", location: nil)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeLoadingFeed([feedImage0, feedImage1])
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [feedImage0.url])
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [feedImage0.url, feedImage1.url])
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisible() {
        let feedImage0 = makeFeedImage(description: "a description", location: "a location")
        let feedImage1 = makeFeedImage(description: "a description", location: nil)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeLoadingFeed([feedImage0, feedImage1])
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [feedImage0.url])
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [feedImage0.url, feedImage1.url])
    }
    
    func test_feedImageView_showsLoadingIndicatorWhileVisible() {
        let feedImage0 = makeFeedImage(description: "a description", location: "a location")
        let feedImage1 = makeFeedImage(description: "a description", location: nil)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeLoadingFeed([feedImage0, feedImage1])
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        let view1 = sut.simulateFeedImageViewVisible(at: 0)
        let view2 = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true)
        XCTAssertEqual(view2?.isShowingLoadingIndicator, true)
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view2?.isShowingLoadingIndicator, true)
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view2?.isShowingLoadingIndicator, false)
    }
    
    func test_feedImageView_showsRetryButtonWhenImageLoadingFails() {
        let feedImage0 = makeFeedImage(description: "a description", location: "a location")
        let feedImage1 = makeFeedImage(description: "a description", location: nil)
        let feedImage2 = makeFeedImage(description: "a description", location: nil)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeLoadingFeed([feedImage0, feedImage1, feedImage2])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryButton, false)
        XCTAssertEqual(view1?.isShowingRetryButton, false)
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingRetryButton, false)
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view1?.isShowingRetryButton, true)
        
        view1?.simulateButtonTapped()
        loader.completeImageLoading(at: 2)
        XCTAssertEqual(view1?.isShowingRetryButton, false)
    }
        
    // MARK: - Helper
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let feedViewController = FeedViewController(feedLoader: loader, imageDataLoader: loader)
        
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
    
    class TaskSpy: ImageDataLoaderTask {
        let handler: () -> Void
        init(handler: @escaping () -> Void) {
            self.handler = handler
        }
        
        func cancel() {
            handler()
        }
    }
   
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: - Feed Loader
        var loadFeedCalls: Int {
            feedFetchingCompletions.count
        }
        
        var feedFetchingCompletions: [(FeedLoader.Result) -> Void] = []
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedFetchingCompletions.append(completion)
        }
        
        func completeLoadingFeed(_ feeds: [FeedImage] = [], at index: Int = 0) {
            feedFetchingCompletions[index](.success(feeds))
        }
        
        func completeLoadingFeedWithError(_ error: Error = anyNSError(), at index: Int = 0) {
            feedFetchingCompletions[index](.failure(error))
        }
        
        // MARK: - Image Data Loader
        var imageRequest = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var loadedImageURLs: [URL] {
            imageRequest.map(\.url)
        }
        var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
            imageRequest.append((url, completion))
            
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(at index: Int, data: Data = Data()) {
            imageRequest[index].completion(.success(data))
        }
        
        func completeImageLoadingWithError(_ error: Error = anyNSError(), at index: Int) {
            imageRequest[index].completion(.failure(error))
        }
    }
}

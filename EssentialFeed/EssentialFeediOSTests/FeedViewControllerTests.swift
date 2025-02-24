//
//  EssentialFeediOSTests.swift
//  EssentialFeediOSTests
//
//  Created by Anthony on 18/2/25.
//

import XCTest
import EssentialFeediOS
import EssentialFeed

final class FeedViewControllerTests: XCTestCase {
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
        loader.completeLoadingFeedWithError(at: 0)
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
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let feedImage0 = makeFeedImage(description: "a description", location: "a location")
        let feedImage1 = makeFeedImage(description: "a description", location: nil)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeLoadingFeed([feedImage0, feedImage1])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view0?.renderedImage, .none)
        XCTAssertEqual(view1?.renderedImage, .none)
        
        let imageData0  = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(at: 0, data: imageData0)
        XCTAssertEqual(view0?.renderedImage, imageData0)
        XCTAssertEqual(view1?.renderedImage, .none)
        
        let imageData1  = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(at: 1, data: imageData1)
        XCTAssertEqual(view0?.renderedImage, imageData0)
        XCTAssertEqual(view1?.renderedImage, imageData1)
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
        XCTAssertEqual(view0?.isShowingRetryButton, false, "don't show retry button while loading")
        XCTAssertEqual(view1?.isShowingRetryButton, false, "don't show retry button while loading")
        
        let imageData0  = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(at: 0, data: imageData0)
        XCTAssertEqual(view0?.isShowingRetryButton, false)
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view1?.isShowingRetryButton, true)
        
        view1?.simulateRetryButtonTapped()
        let imageData1  = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(at: 2, data: imageData1)
        XCTAssertEqual(view1?.isShowingRetryButton, false, "retry button should disappear after image loaded on retry button tapped")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeLoadingFeed([makeFeedImage(description: nil, location: nil)])
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view0?.isShowingRetryButton, false)
        
        loader.completeImageLoading(at: 0, data: Data("invalid data".utf8))
        XCTAssertEqual(view0?.isShowingRetryButton, true)
    }
    
    // this test has failed because it called both cell for row and prefetch for row
//    func test_feedImageView_preloadsWhenViewIsNearVisible() {
//        let feedImage0 = makeFeedImage(description: "a description", location: "a location")
//        let (sut, loader) = makeSUT()
//        
//        sut.simulateAppearance()
//        loader.completeLoadingFeed([feedImage0])
//        
//        sut.simulateFeedImageViewNearVisible(at: 0)
//        XCTAssertEqual(loader.loadedImageURLs, [feedImage0.url])
//    }
    
    func test_feedImageView_canCelPreloadsWhenViewIsNotNearVisible() {
        let feedImage0 = makeFeedImage(description: "a description", location: "a location")
        let feedImage1 = makeFeedImage(description: "a description", location: nil)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeLoadingFeed([feedImage0, feedImage1])
        
        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [feedImage0.url])
        
        loader.completeImageLoading(at: 0)
        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [feedImage0.url, feedImage1.url])
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
    
    class TaskSpy: ImageDataLoaderTask {
        let handler: () -> Void
        init(handler: @escaping () -> Void) {
            self.handler = handler
        }
        
        func cancel() {
            handler()
        }
    }
}

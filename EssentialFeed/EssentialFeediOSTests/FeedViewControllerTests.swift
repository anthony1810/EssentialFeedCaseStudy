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
        
        sut.triggerViewDidLoad()
        sut.triggerViewWillAppear()
        
        sut.replaceRefreshControlWithFakeForiOS17Support()
        XCTAssertEqual(loader.loadCompletionResult.count, 1)
        
        sut.userInitiatedRefresh()
        XCTAssertEqual(loader.loadCompletionResult.count, 2)
        
        sut.userInitiatedRefresh()
        XCTAssertEqual(loader.loadCompletionResult.count, 3)
    }
    
    func test_loadFeeds_showHideIndicatorCorrectly() throws {
        let (sut, loader) = makeSUT()
        
        sut.triggerViewDidLoad()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        XCTAssertEqual(sut.isShowingLoadingIndicator(), false)
        
        sut.triggerViewWillAppear()
        XCTAssertEqual(sut.isShowingLoadingIndicator(), true)
        
        loader.completeFeedLoadingSuccess(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator(), false)
        
        sut.userInitiatedRefresh()
        XCTAssertEqual(sut.isShowingLoadingIndicator(), true)
        
        loader.completeFeedLoadingWithFailure(at: 1, error: makeAnyError())
        XCTAssertEqual(sut.isShowingLoadingIndicator(), false)
        
        sut.triggerViewWillAppear()
        XCTAssertEqual(sut.isShowingLoadingIndicator(), false)
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() throws {
        let image0 = makeFeedImage(location: "any location", description: "any description", imageURL: makeAnyUrl())
        let image1 = makeFeedImage(location: nil, description: "any description", imageURL: makeAnyUrl())
        let image2 = makeFeedImage(location: "any location", description: nil, imageURL: makeAnyUrl())
        let image3 = makeFeedImage(location: nil, description: nil, imageURL: makeAnyUrl())
        let (sut, loader) = makeSUT()

        sut.triggerViewDidLoad()
        sut.triggerViewWillAppear()
        assert(sut: sut, rendering: [])
        
        loader.completeFeedLoadingSuccess(at: 0, with: [image0])
        assert(sut: sut, rendering: [image0])
        
        sut.userInitiatedRefresh()
        loader.completeFeedLoadingSuccess(at: 0, with: [image0, image1, image2, image3])
        assert(sut: sut, rendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_rendersErrorDoesNotAlterCurrentState() throws {
        let image0 = makeFeedImage(location: "any location", description: "any description", imageURL: makeAnyUrl())
        let (sut, loader) = makeSUT()
        
        sut.triggerViewDidLoad()
        
        sut.triggerViewWillAppear()
        loader.completeFeedLoadingSuccess(at: 0, with: [image0])
        assert(sut: sut, rendering: [image0])
        
        let error = makeAnyError()
        sut.userInitiatedRefresh()
        loader.completeFeedLoadingWithFailure(at: 1, error: error)
        assert(sut: sut, rendering: [image0])
    }
    
    func test_loadFeedCompletion_redersImageWhenImageViewIsVisible() throws {
        let image0 = makeFeedImage(location: "any location", description: "any description", imageURL: makeAnyUrl())
        let image1 = makeFeedImage(location: nil, description: "any description", imageURL: makeAnyUrl())
        let image2 = makeFeedImage(location: "any location", description: nil, imageURL: makeAnyUrl())
        let (sut, loader) = makeSUT()
        
        sut.triggerViewDidLoad()
        
        sut.userInitiatedRefresh()
        loader.completeFeedLoadingSuccess(at: 0, with: [image0, image1, image2])
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expect no image when view is not visible")
        
        sut.stimulateVisibleView(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL], "Expect one image when one view is visible")
        
        sut.userInitiatedRefresh()
        sut.stimulateVisibleView(at: 1)
        
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expect two image are loaded when one more view is visible")
    }
    
}

extension FeedViewControllerTests {
    func assert(sut: FeedViewController, rendering images: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), images.count)
        
        for (index, image) in images.enumerated() {
            assert(sut: sut, hasConfigureFeedImageViewAt: index, with: image, file: file, line: line)
        }
    }
    
    func assert(sut: FeedViewController, hasConfigureFeedImageViewAt index: Int, with image: FeedImage, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index) as? FeedImageCell
        XCTAssertNotNil(view, file: file, line: line)
        XCTAssertEqual(view?.locationText, image.location, file: file, line: line)
        XCTAssertEqual(view?.descriptionText, image.description, file: file, line: line)
        XCTAssertEqual(view?.url, image.imageURL, file: file, line: line)
    }
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader, imageLoader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    func makeFeedImage(location: String?, description: String?, imageURL: URL) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, imageURL: imageURL)
    }
}



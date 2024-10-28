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
        
        XCTAssertEqual(loader.feedRequests.count, 0)
        
        sut.triggerViewDidLoad()
        sut.triggerViewWillAppear()
        
        sut.replaceRefreshControlWithFakeForiOS17Support()
        XCTAssertEqual(loader.feedRequests.count, 1)
        
        sut.userInitiatedRefresh()
        XCTAssertEqual(loader.feedRequests.count, 2)
        
        sut.userInitiatedRefresh()
        XCTAssertEqual(loader.feedRequests.count, 3)
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
    
    func test_feedImageLoadingIndicator_isVisibleWhileLoadingImage() throws {
        let image0 = makeFeedImage(location: "any location", description: "any description", imageURL: makeAnyUrl())
        let image1 = makeFeedImage(location: nil, description: "any description", imageURL: makeAnyUrl())
        let (sut, loader) = makeSUT()
        
        sut.triggerViewDidLoad()
        
        sut.userInitiatedRefresh()
        loader.completeFeedLoadingSuccess(at: 0, with: [image0, image1])
        
        let imageView0 = sut.stimulateVisibleView(at: 0) as? FeedImageCell
        let imageView1 = sut.stimulateVisibleView(at: 1) as? FeedImageCell
        XCTAssertEqual(imageView0?.isShowingImageLoadingIndicator(), true, "Expect loading image indicator at 0 index")
        XCTAssertEqual(imageView1?.isShowingImageLoadingIndicator(), true, "Expect loading image indicator at 1 index")
        
        loader.completeImageLoadingSuccessfully(at: 0)
        XCTAssertEqual(imageView0?.isShowingImageLoadingIndicator(), false, "Expect loading image indicator at 0 index")
        XCTAssertEqual(imageView1?.isShowingImageLoadingIndicator(), true, "Expect loading image indicator at 1 index")
        
        loader.completeImageLoadingWithFailure(at: 1, error: makeAnyError())
        XCTAssertEqual(imageView0?.isShowingImageLoadingIndicator(), false, "Expect loading image indicator at 0 index")
        XCTAssertEqual(imageView1?.isShowingImageLoadingIndicator(), false, "Expect loading image indicator at 1 index")
    }
    
    func test_loadFeedCompletion_cancelRendersImageWhenImageViewIsNotVisible() throws {
        let image0 = makeFeedImage(location: "any location", description: "any description", imageURL: makeAnyUrl())
        let image1 = makeFeedImage(location: nil, description: "any description", imageURL: makeAnyUrl())
        let image2 = makeFeedImage(location: "any location", description: nil, imageURL: makeAnyUrl())
        let (sut, loader) = makeSUT()
        
        sut.triggerViewDidLoad()
        
        sut.userInitiatedRefresh()
        loader.completeFeedLoadingSuccess(at: 0, with: [image0, image1, image2])
        
        XCTAssertEqual(loader.cancelLoadedImageURLs, [], "Expect no image when view is not visible")
        
        sut.stimulateViewDisappear(at: 0)
        XCTAssertEqual(loader.cancelLoadedImageURLs, [image0.imageURL], "Expect one image when one view is visible")
        
        sut.userInitiatedRefresh()
        sut.stimulateViewDisappear(at: 1)
        
        XCTAssertEqual(loader.cancelLoadedImageURLs, [image0.imageURL, image1.imageURL], "Expect two image are loaded when one more view is visible")
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() throws {
        let image0 = makeFeedImage(location: "any location", description: "any description", imageURL: makeAnyUrl())
        let image1 = makeFeedImage(location: nil, description: "any description", imageURL: makeAnyUrl())
        let (sut, loader) = makeSUT()
        
        sut.triggerViewDidLoad()
        
        sut.userInitiatedRefresh()
        loader.completeFeedLoadingSuccess(at: 0, with: [image0, image1])
        
        let imageView0 = sut.stimulateVisibleView(at: 0) as? FeedImageCell
        let imageView1 = sut.stimulateVisibleView(at: 1) as? FeedImageCell
        XCTAssertEqual(imageView0?.renderedImage, .none, "Expect no image data while loading at 0 index")
        XCTAssertEqual(imageView1?.renderedImage, .none, "Expect no image data while loading at 1 index")
        
        let image0Data = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoadingSuccessfully(at: 0, with: image0Data)
        XCTAssertEqual(imageView0?.renderedImage, image0Data, "Expect loading image indicator at 0 index")
        XCTAssertEqual(imageView1?.renderedImage, .none, "Expect loading image indicator at 1 index")
        
        let image1Data = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoadingSuccessfully(at: 1, with: image1Data)
        XCTAssertEqual(imageView0?.renderedImage, image0Data, "Expect data at 0 index")
        XCTAssertEqual(imageView1?.renderedImage, image1Data, "Expect data at 1 index")
    }
    
    func test_feedImageView_showingRetryActionWhenLoadingImageFail() throws {
        let image0 = makeFeedImage(location: "any location", description: "any description", imageURL: makeAnyUrl())
        let image1 = makeFeedImage(location: nil, description: "any description", imageURL: makeAnyUrl())
        let (sut, loader) = makeSUT()
        
        sut.triggerViewDidLoad()
        
        sut.userInitiatedRefresh()
        loader.completeFeedLoadingSuccess(at: 0, with: [image0, image1])
        
        let imageView0 = sut.stimulateVisibleView(at: 0) as? FeedImageCell
        let imageView1 = sut.stimulateVisibleView(at: 1) as? FeedImageCell
        XCTAssertEqual(imageView0?.showingRetryButton, false, "Expect hidden retrieve button while loading")
        XCTAssertEqual(imageView1?.showingRetryButton, false, "Expect hidden retrieve button while loading")
        
        let image0Data = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoadingSuccessfully(at: 0, with: image0Data)
        XCTAssertEqual(imageView0?.showingRetryButton, false, "Expect hidden retrieve button while loading complete successully")
        XCTAssertEqual(imageView1?.showingRetryButton, false, "Expect hidden retrieve button while not loading")
        
        loader.completeImageLoadingWithFailure(at: 1, error: makeAnyError())
        XCTAssertEqual(imageView0?.showingRetryButton, false, "Expect hidden retrieve button while loading complete successully")
        XCTAssertEqual(imageView1?.showingRetryButton, true, "Expect showing retrieve button while loading failed")
    }
    
    func test_feedImageView_showingRetryButtonWhenLoadingInvalidImageData() throws {
        let image0 = makeFeedImage(location: "any location", description: "any description", imageURL: makeAnyUrl())
        let image1 = makeFeedImage(location: nil, description: "any description", imageURL: makeAnyUrl())
        let (sut, loader) = makeSUT()
        
        sut.triggerViewDidLoad()
        
        sut.userInitiatedRefresh()
        loader.completeFeedLoadingSuccess(at: 0, with: [image0, image1])
        
        let imageView0 = sut.stimulateVisibleView(at: 0) as? FeedImageCell
        sut.userInitiatedRefresh()
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoadingSuccessfully(at: 0, with: invalidImageData)
        
        XCTAssertEqual(imageView0?.retryButton.isHidden, false)
    }
    
    func test_feedImageViewRetryAction_reloadsFeed() throws {
        let image0 = makeFeedImage(location: "any location", description: "any description", imageURL: makeAnyUrl())
        let image1 = makeFeedImage(location: nil, description: "any description", imageURL: makeAnyUrl())
        let (sut, loader) = makeSUT()
        
        sut.triggerViewDidLoad()
        
        sut.userInitiatedRefresh()
        loader.completeFeedLoadingSuccess(at: 0, with: [image0, image1])
        
        let imageView0 = sut.stimulateVisibleView(at: 0) as? FeedImageCell
        let imageView1 = sut.stimulateVisibleView(at: 1) as? FeedImageCell
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "expect only two images url request fired when two cell visible")
        
        loader.completeImageLoadingWithFailure(at: 0, error: makeAnyError())
        loader.completeImageLoadingWithFailure(at: 1, error: makeAnyError())
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "expect still only two images url request fired when two cell isn't retrying")
        
        imageView0?.triggerRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL, image0.imageURL], "expect oen more image url request fired when two cell retrying")
        
        imageView1?.triggerRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL, image0.imageURL, image1.imageURL], "expect two more images url request fired when two cell retrying")
        
    }
    
}

// MARK: - Helpers

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



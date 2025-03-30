//
//  FeedImagePresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation
import EssentialFeed
import XCTest

struct FeedImageViewModel<Image> {
    var location: String?
    var description: String?
    var image: Image?
    var isLoading: Bool
    var shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}

protocol FeedImageView {
    associatedtype Image
    func display(viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(
            viewModel: FeedImageViewModel(
                location: model.location,
                description: model.description,
                isLoading: true,
                shouldRetry: false)
        )
    }
    
    func didFinishedLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(viewModel: FeedImageViewModel(
            location: model.location,
            description: model.description,
            isLoading: false,
            shouldRetry: true)
        )
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishedLoadingImageData(with data: Data, for model: FeedImage) {
        guard let _ = imageTransformer(data) else {
            return didFinishedLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(viewModel: FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: imageTransformer(data),
            isLoading: false,
            shouldRetry: false)
        )
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotMessageView() {
        let (_, viewSpy) = makeSUT()
        
        XCTAssertTrue(viewSpy.messages.isEmpty)
    }
    
    func test_didStartLoadingImage_displaysLoadingImage() {
        let (sut, viewSpy) = makeSUT()
        let feed = uniqueFeed().model
        sut.didStartLoadingImageData(for: feed)
        
        let message = viewSpy.messages.first
        XCTAssertEqual(viewSpy.messages.count, 1)
        XCTAssertEqual(message?.location, feed.location)
        XCTAssertEqual(message?.description, feed.description)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_finishedLoadingImageDataWithError_hideLoadingIndicatorAndShowRetryButton() {
        let (sut, viewSpy) = makeSUT()
        let feed = uniqueFeed().model
        
        sut.didFinishedLoadingImageData(with: anyNSError(), for: feed)
        
        let message = viewSpy.messages.first
        XCTAssertEqual(viewSpy.messages.count, 1)
        XCTAssertEqual(message?.location, feed.location)
        XCTAssertEqual(message?.description, feed.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
    }
    
    func test_didFinishedLoadingImageDataWithInvalidData_hideLoadingIndicatorAndShowRetryButton() {
        let (sut, viewSpy) = makeSUT(imageTransformer: failImageTransformer)
        let feed = uniqueFeed().model
        let invalidImageData = Data()
        
        sut.didFinishedLoadingImageData(with: invalidImageData, for: feed)
        
        let message = viewSpy.messages.first
        XCTAssertEqual(viewSpy.messages.count, 1)
        XCTAssertEqual(message?.location, feed.location)
        XCTAssertEqual(message?.description, feed.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishedLoadingImageData_displaysImageOnSuccessfulTransformation() {
        let feed = uniqueFeed().model
        let validImageData = Data()
        let transformedData = AnyImage()
        let (sut, viewSpy) = makeSUT(imageTransformer: {_ in transformedData })
        
        sut.didFinishedLoadingImageData(with: validImageData, for: feed)
        
        let message = viewSpy.messages.first
        XCTAssertEqual(viewSpy.messages.count, 1)
        XCTAssertEqual(message?.location, feed.location)
        XCTAssertEqual(message?.description, feed.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformedData)
    }
    
    // MARK: - Helpers
    private func makeSUT(
        imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedImagePresenter(view: viewSpy, imageTransformer: imageTransformer)
        
        trackMemoryLeaks(viewSpy, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, viewSpy)
    }
    
    private var failImageTransformer: (Data) -> AnyImage? {
        { _ in nil }
    }
    
    private struct AnyImage: Equatable {}
    
    private final class ViewSpy: FeedImageView {
        var messages = [FeedImageViewModel<AnyImage>]()
        enum Message {
            case display(FeedImageViewModel<AnyImage>)
        }
        
        func display(viewModel: FeedImageViewModel<AnyImage>) {
            messages.append(viewModel)
        }
    }
    
}

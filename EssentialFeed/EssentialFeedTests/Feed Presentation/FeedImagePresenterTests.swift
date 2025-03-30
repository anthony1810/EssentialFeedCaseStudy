//
//  FeedImagePresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation
import EssentialFeed
import XCTest

struct FeedImageViewModel {
    var location: String?
    var description: String?
    var image: Any?
    var isLoading: Bool
    var shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}

protocol FeedImageView {
    func display(viewModel: FeedImageViewModel)
}

final class FeedImagePresenter {
    
    private let view: FeedImageView
    private let imageTransformer: (Data) -> Any?
    
    init(view: FeedImageView, imageTransformer: @escaping (Data) -> Any?) {
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
    
    // MARK: - Helpers
    private func makeSUT(
        imageTransformer: @escaping (Data) -> Any? = { _ in nil },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedImagePresenter(view: viewSpy, imageTransformer: imageTransformer)
        
        trackMemoryLeaks(viewSpy, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, viewSpy)
    }
    
    private var failImageTransformer: (Data) -> Any? {
        { _ in nil }
    }
    
    private final class ViewSpy: FeedImageView {
        var messages = [FeedImageViewModel]()
        enum Message {
            case display(FeedImageViewModel)
        }
        
        func display(viewModel: FeedImageViewModel) {
            messages.append(viewModel)
        }
    }
    
}

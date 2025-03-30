//
//  FeedImagePresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation
import EssentialFeed
import XCTest

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

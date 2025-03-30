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
    
    init(view: FeedImageView) {
        self.view = view
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
    
    func test_FinishedLoadingImageDataWithError_hideLoadingIndicatorAndShowRetryButton() {
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
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedImagePresenter(view: viewSpy)
        
        trackMemoryLeaks(viewSpy, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, viewSpy)
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

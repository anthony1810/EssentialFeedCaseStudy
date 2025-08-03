//
//  FeedPresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation
import EssentialFeed
import XCTest

final class FeedPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
    
    func test_init_doesNotSendMessageToView() {
        let (_, viewSpy) = makeSUT()
        XCTAssertTrue(viewSpy.receivedMessages.isEmpty, "Expect no view messages yet.")
    }
    
    func test_didStartLoading_displayNoErrorMessageAndShowLoading() {
        let (sut, viewSpy) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(
            viewSpy.receivedMessages,
            [
                .display(isLoading: true),
                .display(errorMessage: .none)
            ]
        )
    }
    
    func test_didFinishLoadingWithError_displayLoadErrorAndHideLoading() {
        let (sut, viewSpy) = makeSUT()
        
        sut.didFinishLoading(with: anyNSError())
        
        XCTAssertEqual(
            viewSpy.receivedMessages,
            [
                .display(errorMessage: localized("GENERIC_CONNECTION_ERROR", table: "Shared")),
                .display(isLoading: false)
            ]
        )
    }
    
    func test_didFinishLoadingFeed_displaysFeedAndStopLoading() {
        let (sut, viewSpy) = makeSUT()
        let feed = [uniqueFeed().model]
        
        sut.display(feeds: feed)
        
        XCTAssertEqual(viewSpy.receivedMessages, [
            .display(isLoading: false),
            .display(errorMessage: .none),
            .display(feed: feed)
        ])
    }
    
    func test_map_createsViewModel() {
        
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedPresenter(loadingView: viewSpy, feedView: viewSpy, errorView: viewSpy)
        
        trackMemoryLeaks(viewSpy, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, viewSpy)
    }
    
    private func localized(_ key: String, table: String = "Feed", file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localization for key: \(key) in table \(table)", file: file, line: line)
        }
        
        return value
    }
    
    private class ViewSpy: ResourceErrorView, ResourceLoadingView, FeedView {
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        var receivedMessages = Set<Message>()
        
        func display(_ viewModel: ResourceErrorViewModel) {
            receivedMessages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(viewModel: ResourceLoadingViewModel) {
            receivedMessages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(viewModel: FeedViewModel) {
            receivedMessages.insert(.display(feed: viewModel.feeds))
        }
    }
}

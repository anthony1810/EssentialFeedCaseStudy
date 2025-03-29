//
//  FeedPresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation
import EssentialFeed
import XCTest

struct LoadingViewModel {
    var isLoading: Bool
}
protocol FeedLoadingView {
    func display(viewModel: LoadingViewModel)
}

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: Self {
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

struct FeedViewModel {
    var feeds: [FeedImage]
}
protocol FeedView {
    func display(viewModel: FeedViewModel)
}



final class FeedPresenter {
    private let loadingView: FeedLoadingView
    private let feedView: FeedView
    private let errorView: FeedErrorView
    
    static var loadError: String {
        NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Load error for the feed view"
        )
    }
    
    init(loadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    func didStartLoading() {
        self.errorView.display(.noError)
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: true))
    }
    
    func didFinishLoading(with error: Error) {
        self.errorView.display(.error(message: FeedPresenter.loadError))
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: false))
    }
    
    func display(feeds: [FeedImage]) {
        self.feedView.display(viewModel: FeedViewModel(feeds: feeds))
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: false))
        self.errorView.display(.noError)
    }
}

final class FeedPresenterTests: XCTestCase {
    
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
                .display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
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
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedPresenter(loadingView: viewSpy, feedView: viewSpy, errorView: viewSpy)
        
        trackMemoryLeaks(viewSpy, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, viewSpy)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenterTests.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localization for key: \(key) in table \(table)", file: file, line: line)
        }
        
        return value
    }
    
    private class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        var receivedMessages = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            receivedMessages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(viewModel: LoadingViewModel) {
            receivedMessages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(viewModel: FeedViewModel) {
            receivedMessages.insert(.display(feed: viewModel.feeds))
        }
    }
}

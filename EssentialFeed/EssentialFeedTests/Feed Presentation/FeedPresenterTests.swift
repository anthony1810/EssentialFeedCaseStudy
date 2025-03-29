//
//  FeedPresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation
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


final class FeedPresenter {
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    static var loadError: String {
        NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Load error for the feed view"
        )
    }
    
    init(loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.loadingView = loadingView
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
                .display(errorMessage: FeedPresenter.loadError),
                .display(isLoading: false)
            ]
        )
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedPresenter(loadingView: viewSpy, errorView: viewSpy)
        
        trackMemoryLeaks(viewSpy, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, viewSpy)
    }
    private class ViewSpy: FeedErrorView, FeedLoadingView {
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        var receivedMessages = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            receivedMessages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(viewModel: LoadingViewModel) {
            receivedMessages.insert(.display(isLoading: viewModel.isLoading))
        }
    }
}

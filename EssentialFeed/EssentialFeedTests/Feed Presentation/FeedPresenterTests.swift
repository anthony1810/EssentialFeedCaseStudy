//
//  FeedPresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation
import XCTest

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: Self {
        FeedErrorViewModel(message: nil)
    }
}
protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}


final class FeedPresenter {
    private let errorView: FeedErrorView
    
    init(errorView: FeedErrorView) {
        self.errorView = errorView
    }
    
    func didStartLoading() {
        self.errorView.display(.noError)
    }
}

final class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let (_, viewSpy) = makeSUT()
        XCTAssertTrue(viewSpy.receivedMessages.isEmpty, "Expect no view messages yet.")
    }
    
    func test_didStartLoading_displayNoErrorMessage() {
        let (sut, viewSpy) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(viewSpy.receivedMessages, [.display(.none)])
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedPresenter(errorView: viewSpy)
        
        trackMemoryLeaks(viewSpy, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, viewSpy)
    }
    private class ViewSpy: FeedErrorView {
        
        enum Message: Equatable {
            case display(_ viewModel: String?)
        }
        var receivedMessages = [Message]()
        
        func display(_ viewModel: FeedErrorViewModel) {
            receivedMessages.append(.display(.none))
        }
    }
}

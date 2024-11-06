//
//  FeedPrensenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 5/11/24.
//

import Foundation
import XCTest

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
}

protocol FeedErrorViewProtocol {
    func display(_ viewModel: FeedErrorViewModel)
}

class FeedPresenter {
    var errorView: FeedErrorViewProtocol
    
    init(errorView: FeedErrorViewProtocol) {
        self.errorView = errorView
    }
    
    func startLoading() {
        errorView.display(.noError)
    }
}

class FeedPrensenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let (_, viewSpy) = makeSUT()
        
        XCTAssertTrue(viewSpy.messages.isEmpty)
    }
    
    func test_startLoading_doesNotShowErrorView() {
        let (sut, viewSpy) = makeSUT()
        
        sut.startLoading()
        
        XCTAssertEqual(viewSpy.messages, [.display(message: nil)])
    }
}

extension FeedPrensenterTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedPresenter(errorView: viewSpy)
        
        trackForMemoryLeaks(viewSpy)
        trackForMemoryLeaks(sut)
        
        return (sut: sut, view: viewSpy)
    }
}

extension FeedPrensenterTests {
    private class ViewSpy: FeedErrorViewProtocol {

        enum Message: Equatable {
            case display(message: String?)
        }
        private(set) var messages: [Message] = []
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(message: viewModel.message))
        }
    
    }
}

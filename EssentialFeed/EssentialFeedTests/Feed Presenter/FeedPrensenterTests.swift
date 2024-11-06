//
//  FeedPrensenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 5/11/24.
//

import Foundation
import XCTest

struct FeedLoadingViewModel {
    let isLoading: Bool
    
    static var isLoading: FeedLoadingViewModel {
        return FeedLoadingViewModel(isLoading: true)
    }
    
    static var noLoading: FeedLoadingViewModel {
        return FeedLoadingViewModel(isLoading: false)
    }
}

protocol FeedLoadingViewProtocol {
    func display(_ viewModel: FeedLoadingViewModel)
}


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
    var loadingView: FeedLoadingViewProtocol
    var errorView: FeedErrorViewProtocol
    
    init(loadingView: FeedLoadingViewProtocol, errorView: FeedErrorViewProtocol) {
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func startLoading() {
        loadingView.display(.isLoading)
        errorView.display(.noError)
    }
}

class FeedPrensenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let (_, viewSpy) = makeSUT()
        
        XCTAssertTrue(viewSpy.messages.isEmpty)
    }
    
    func test_startLoading_doesNotShowErrorViewAndDisplayLoading() {
        let (sut, viewSpy) = makeSUT()
        
        sut.startLoading()
        
        XCTAssertEqual(viewSpy.messages, [
            .display(message: nil),
            .display(loading: true)
        ])
    }
}

extension FeedPrensenterTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedPresenter(loadingView: viewSpy, errorView: viewSpy)
        
        trackForMemoryLeaks(viewSpy)
        trackForMemoryLeaks(sut)
        
        return (sut: sut, view: viewSpy)
    }
}

extension FeedPrensenterTests {
    private class ViewSpy: FeedErrorViewProtocol, FeedLoadingViewProtocol {
       
        enum Message: Hashable {
            case display(message: String?)
            case display(loading: Bool)
        }
        
        private(set) var messages: Set<Message> = []
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(message: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(loading: viewModel.isLoading))
        }
    }
}

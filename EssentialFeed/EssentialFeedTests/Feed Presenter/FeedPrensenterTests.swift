//
//  FeedPrensenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 5/11/24.
//

import Foundation
import XCTest
import EssentialFeed

struct FeedFetchingViewModel {
    let feeds: [FeedImage]
}

protocol FeedFetchingViewProtocol {
    func display(viewModel: FeedFetchingViewModel)
}

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
    var fetchingView: FeedFetchingViewProtocol
    
    init(loadingView: FeedLoadingViewProtocol, errorView: FeedErrorViewProtocol, fetchingView: FeedFetchingViewProtocol) {
        self.loadingView = loadingView
        self.errorView = errorView
        self.fetchingView = fetchingView
    }
    
    func startLoading() {
        loadingView.display(.isLoading)
        errorView.display(.noError)
    }
    
    func finishLoadingSuccessfully(feeds: [FeedImage]) {
        fetchingView.display(viewModel: FeedFetchingViewModel(feeds: feeds))
        loadingView.display(.noLoading)
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
    
    func test_didFinishLoading_displaysFeedAndStopLoading() {
        let (sut, viewSpy) = makeSUT()
        let feeds: [FeedImage] = [uniqueItem().domainModel, uniqueItem().domainModel]
        
        sut.finishLoadingSuccessfully(feeds: feeds)
        
        XCTAssertEqual(viewSpy.messages, [
            .display(loading: false),
            .display(feed: feeds)
        ])
    }
}

extension FeedPrensenterTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedPresenter(loadingView: viewSpy, errorView: viewSpy, fetchingView: viewSpy)
        
        trackForMemoryLeaks(viewSpy)
        trackForMemoryLeaks(sut)
        
        return (sut: sut, view: viewSpy)
    }
    
    func uniqueItem() -> (domainModel: FeedImage, localModel: LocalFeedImage) {
        let domain = FeedImage(id: UUID(), description: nil, location: nil, imageURL: makeAnyUrl())
        let local = LocalFeedImage(id: domain.id, description: domain.description, location: domain.location, url: domain.imageURL)
        
        return (domain, local)
    }
}

extension FeedPrensenterTests {
    private class ViewSpy: FeedErrorViewProtocol, FeedLoadingViewProtocol, FeedFetchingViewProtocol {
       
        enum Message: Hashable {
            case display(message: String?)
            case display(loading: Bool)
            case display(feed: [FeedImage])
        }
        
        private(set) var messages: Set<Message> = []
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(message: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(loading: viewModel.isLoading))
        }
        
        func display(viewModel: FeedFetchingViewModel) {
            messages.insert(.display(feed: viewModel.feeds))
        }
    }
}

extension FeedImage: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//
//  FeedPrensenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 5/11/24.
//

import Foundation
import XCTest
import EssentialFeed

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
    
    func test_didFinishLoadingWithError_displaysErrorAndStopLoading() {
        let (sut, viewSpy) = makeSUT()
        let error: Error = makeAnyError()
        
        sut.finishLoadingFailure(error: error)
        
        XCTAssertEqual(viewSpy.messages, [
            .display(loading: false),
            .display(message: localized("GENERIC_CONNECTION_ERROR", table: "Shared"))
        ])
    }
    
    func test_title_isLocalized() {
        let (sut, _) = makeSUT()
        
        XCTAssertEqual(sut.title, localized("FEED_VIEW_TITLE"))
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
    
    func localized(_ key: String, table: String = "Feed", file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}

extension FeedPrensenterTests {
    private class ViewSpy: LoadResourceErrorViewProtocol, ResourceLoadingViewProtocol, FeedFetchingViewProtocol {
       
        enum Message: Hashable {
            case display(message: String?)
            case display(loading: Bool)
            case display(feed: [FeedImage])
        }
        
        private(set) var messages: Set<Message> = []
        
        func display(_ viewModel: LoadResourceErrorViewModel) {
            messages.insert(.display(message: viewModel.message))
        }
        
        func display(_ viewModel: ResourceLoadingViewModel) {
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

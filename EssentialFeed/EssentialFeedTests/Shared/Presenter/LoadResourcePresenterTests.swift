//
//  LoadSourcePresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 7/12/24.
//

import Foundation
import XCTest
import EssentialFeed

class LoadResourcePresenterTests: XCTestCase {
    
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
        let (sut, viewSpy) = makeSUT(mapper: { resource in
            resource + " view model"
        })
        
        sut.finishLoadingSuccessfully(with: "resource")
        
        XCTAssertEqual(viewSpy.messages, [
            .display(loading: false),
            .display(viewModel: "resource view model")
        ])
    }
    
    func test_didFinishLoadingWithError_displaysErrorAndStopLoading() {
        let (sut, viewSpy) = makeSUT()
        let error: Error = makeAnyError()
        
        sut.finishLoadingFailure(error: error)
        
        XCTAssertEqual(viewSpy.messages, [
            .display(loading: false),
            .display(message: localized("GENERIC_CONNECTION_ERROR"))
        ])
    }
}

extension LoadResourcePresenterTests {
    private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    private func makeSUT(
        mapper: @escaping SUT.Mapper = { _ in "any" },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: SUT, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = SUT(loadingView: viewSpy, errorView: viewSpy, fetchingView: viewSpy, mapper: mapper)
        
        trackForMemoryLeaks(viewSpy)
        trackForMemoryLeaks(sut)
        
        return (sut: sut, view: viewSpy)
    }
    
    func uniqueItem() -> (domainModel: FeedImage, localModel: LocalFeedImage) {
        let domain = FeedImage(id: UUID(), description: nil, location: nil, imageURL: makeAnyUrl())
        let local = LocalFeedImage(id: domain.id, description: domain.description, location: domain.location, url: domain.imageURL)
        
        return (domain, local)
    }
    
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Shared"
        let bundle = Bundle(for: SUT.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}

extension LoadResourcePresenterTests {
    private class ViewSpy: FeedErrorViewProtocol, FeedLoadingViewProtocol, ResourceFetchingViewProtocol {
        typealias ViewModel = String
        enum Message: Hashable {
            case display(message: String?)
            case display(loading: Bool)
            case display(viewModel: String)
        }
        
        private(set) var messages: Set<Message> = []
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(message: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(loading: viewModel.isLoading))
        }
        
        func display(viewModel: String) {
            messages.insert(.display(viewModel: viewModel))
        }
    }
}

//
//  LoadResourcePresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 2/8/25.
//

import Foundation
import EssentialFeed
import XCTest

final class LoadResourcePresenterTests: XCTestCase {
    
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
    
    func test_didFinishLoadingResource_displaysResourceAndStopLoading() {
        let (sut, viewSpy) = makeSUT(mapper: { resource in
            resource + " view model"
        })
        
        let resource = "any"
        sut.display(resource: resource)
        
        XCTAssertEqual(viewSpy.receivedMessages, [
            .display(isLoading: false),
            .display(errorMessage: .none),
            .display(resourceViewModel: "any view model")
        ])
    }
    
    // MARK: - Helpers
    private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    
    private func makeSUT(
        mapper: @escaping (String) -> String = { _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: SUT, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = LoadResourcePresenter(
            loadingView: viewSpy,
            resourceView: viewSpy,
            errorView: viewSpy,
            mapper: mapper
        )
        
        trackMemoryLeaks(viewSpy, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, viewSpy)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localization for key: \(key) in table \(table)", file: file, line: line)
        }
        
        return value
    }
    
    private class ViewSpy: FeedErrorView, FeedLoadingView, ResourceView {
        typealias ResourceViewModel = String
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(resourceViewModel: String)
        }
        var receivedMessages = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            receivedMessages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(viewModel: LoadingViewModel) {
            receivedMessages.insert(.display(isLoading: viewModel.isLoading))
        }
                
        func display(_ viewModel: String) {
            receivedMessages.insert(.display(resourceViewModel: viewModel))
        }
    }
}

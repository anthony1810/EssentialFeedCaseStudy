//
//  FeedImagePresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 6/11/24.
//

import Foundation
import EssentialFeed
import XCTest

final class FeedImagePresenter {
    init(view: Any) {
        
    }
}

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendAnyMessage() {
       let (_, view) = makeSUT()
        XCTAssertEqual(view.messages.count, 0)
    }
    
    func test_startLoadingImage_showLoadingAndDoesNotShowRetry() {
        
    }
    
}

extension FeedImagePresenterTests {
    private final class ViewSpy {
        var messages: [Any] = []
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        
        return (sut, view)
    }
}

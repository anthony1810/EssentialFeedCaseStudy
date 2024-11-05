//
//  FeedPrensenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 5/11/24.
//

import Foundation
import XCTest

class FeedPresenter {
    init(view: Any) {
        
    }
}

class FeedPrensenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let (_, viewSpy) = makeSUT()
        
        XCTAssertTrue(viewSpy.messages.isEmpty)
    }
}

extension FeedPrensenterTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedPresenter(view: viewSpy)
        
        trackForMemoryLeaks(viewSpy)
        trackForMemoryLeaks(sut)
        
        return (sut: sut, view: viewSpy)
    }
}

extension FeedPrensenterTests {
    private class ViewSpy {
        private(set) var messages: [Any] = []
        
        
    }
}

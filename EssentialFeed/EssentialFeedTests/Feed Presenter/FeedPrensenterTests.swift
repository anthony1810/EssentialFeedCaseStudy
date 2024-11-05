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
        let viewSpy = ViewSpy()
        _ = FeedPresenter(view: viewSpy)
        
        XCTAssertTrue(viewSpy.messages.isEmpty)
    }
}

extension FeedPrensenterTests {
    private class ViewSpy {
        private(set) var messages: [Any] = []
        
        
    }
}

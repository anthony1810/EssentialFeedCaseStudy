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
        let view = ViewSpy()
        _ = FeedImagePresenter(view: view)
        XCTAssertEqual(view.messages.count, 0)
    }
    
}

extension FeedImagePresenterTests {
    private final class ViewSpy {
        var messages: [Any] = []
    }
}

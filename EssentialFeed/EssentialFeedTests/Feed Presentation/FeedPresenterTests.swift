//
//  FeedPresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation
import XCTest

final class FeedPresenter {
    init(view: Any) {}
}

final class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessageToView() {
        let viewSpy = ViewSpy()
        _ = FeedPresenter(view: viewSpy)
        
        XCTAssertTrue(viewSpy.receivedMessages.isEmpty, "Expect no view messages yet.")
    }
    
    private class ViewSpy {
        let receivedMessages = [Any]()
    }
}

//
//  FeedImagePresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation
import EssentialFeed
import XCTest

final class FeedImagePresenterTests: XCTestCase {func test_mapFeedImage_createsFeedImageViewModel() {
        let feed = uniqueFeed().model
        
        let viewModel = FeedImagePresenter.map(feed)
        
        XCTAssertEqual(viewModel.location, feed.location)
        XCTAssertEqual(viewModel.description, feed.description)
    }
}

//
//  ImageCommentPresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 10/8/25.
//

import Foundation
import EssentialFeed
import XCTest

final class ImageCommentPresenterTests: XCTestCase {
    func test_mapFeedImage_createsFeedImageViewModel() {
        let feed = uniqueFeed().model
        
        let viewModel = ImageCommentPresenter.map(feed)
        
        XCTAssertEqual(viewModel.location, feed.location)
        XCTAssertEqual(viewModel.description, feed.description)
    }
}

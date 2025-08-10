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
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    func test_mapFeedImage_createsFeedImageViewModel() {
        let feed = uniqueFeed().model
        
        let viewModel = ImageCommentPresenter.map(feed)
        
        XCTAssertEqual(viewModel.location, feed.location)
        XCTAssertEqual(viewModel.description, feed.description)
    }
    
    // MARK: - Helpers
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table: String = "ImageComment"
        let bundle = Bundle(for: ImageCommentPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localization for key: \(key) in table \(table)", file: file, line: line)
        }
        
        return value
    }
}

//
//  FeedPresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation
import EssentialFeed
import XCTest

final class FeedPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
    
    func test_mapFeeds_createsFeedViewModel() {
        let feed = uniqueFeed().model
        
        let viewModel = FeedPresenter.map([feed])
        XCTAssertEqual(viewModel.feeds, [feed])
    }
    
    private func localized(_ key: String, table: String = "Feed", file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localization for key: \(key) in table \(table)", file: file, line: line)
        }
        
        return value
    }
}

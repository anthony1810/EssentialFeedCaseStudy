//
//  FeedPrensenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 5/11/24.
//

import Foundation
import XCTest
import EssentialFeed

class FeedPrensenterTests: XCTestCase {
    func test_map_createViewModel() {
        let feed = uniqueItem().domainModel
        
        let viewModel = FeedPresenter.map([feed])
        
        XCTAssertEqual(viewModel.feeds, [feed])
    }
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
}

extension FeedPrensenterTests {
    func uniqueItem() -> (domainModel: FeedImage, localModel: LocalFeedImage) {
        let domain = FeedImage(id: UUID(), description: nil, location: nil, imageURL: makeAnyUrl())
        let local = LocalFeedImage(id: domain.id, description: domain.description, location: domain.location, url: domain.imageURL)
        
        return (domain, local)
    }
    
    func localized(_ key: String, table: String = "Feed", file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}

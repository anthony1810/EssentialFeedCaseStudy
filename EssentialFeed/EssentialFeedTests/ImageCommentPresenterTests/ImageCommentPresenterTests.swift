//
//  ImageCommentPresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 15/12/24.
//

import Foundation
import XCTest
import EssentialFeed

class ImageCommentPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
}

extension ImageCommentPresenterTests {
    func localized(_ key: String, table: String = "ImageComment", file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: ImageCommentPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}

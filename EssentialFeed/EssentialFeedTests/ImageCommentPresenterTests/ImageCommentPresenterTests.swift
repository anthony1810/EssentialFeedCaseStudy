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
    
    func test_map_createsViewModel() {
        
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US")
        
        let comments = [
            ImageComment(
                id: UUID(),
                message: "a message",
                createdAt: now.addingMinutes(-5),
                author: "a username"),
            ImageComment(
                id: UUID(),
                message: "another message",
                createdAt: now.addingDay(-1),
                author: "another username")
        ]
        
        let viewModel = ImageCommentPresenter.map(
            comments,
            calendar: calendar,
            locale: locale,
            currentDate: now
        )
        
        XCTAssertEqual(viewModel.comments, [
            ImageCommentViewModel(
                message: "a message",
                date: "5 minutes ago",
                username: "a username"
            ),
            ImageCommentViewModel(
                message: "another message",
                date: "1 day ago",
                username: "another username"
            )
        ])
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

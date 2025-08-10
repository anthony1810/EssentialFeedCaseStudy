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
    
    func test_mapComments_createsImageCommentsViewModel() {
        let now = Date.now
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        
        let imageComments = [
            ImageComment(
                id: UUID(),
                message: "a message",
                createdAt: now.adding(minutes: -5),
                username: "a user name"
            ),
            ImageComment(
                id: UUID(),
                message: "another message",
                createdAt: now.adding(seconds: -1),
                username: "another user name"
            )
        ]
        
        let viewModel = ImageCommentPresenter.map(
            imageComments,
            currentDate: now,
            locale: locale,
            calendar: calendar
        )
        
        XCTAssertEqual(viewModel.comments, [
            ImageCommentViewModel(
                message: "a message",
                date: "5 minutes ago",
                username: "a user name"
            ),
            ImageCommentViewModel(
                message: "another message",
                date: "1 second ago",
                username: "another user name"
            )
        ])
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

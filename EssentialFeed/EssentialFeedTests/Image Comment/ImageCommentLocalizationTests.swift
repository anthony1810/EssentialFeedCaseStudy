//
//  ImageCommentLocalizationTests.swift
//  EssentialFeed
//
//  Created by Anthony on 10/8/25.
//

import EssentialFeed
import XCTest

final class ImageCommentLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let presentationBundle = Bundle(for: ImageCommentPresenter.self)
        
        assertLocalizedKeyAndValueExist(in: presentationBundle, table)
    }
}

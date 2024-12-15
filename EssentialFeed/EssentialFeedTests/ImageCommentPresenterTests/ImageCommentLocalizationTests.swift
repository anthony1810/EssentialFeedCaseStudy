//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 15/12/24.
//

import XCTest
import EssentialFeed

class ImageCommentLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComment"
        let bundle = Bundle(for: ImageCommentPresenter.self)
        assertLocalizationKeyAndValuesExist(in: bundle, table)
    }
}

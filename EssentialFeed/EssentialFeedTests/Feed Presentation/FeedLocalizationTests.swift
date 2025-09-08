//
//  FeedViewController+Localization.swift
//  EssentialFeed
//
//  Created by Anthony on 23/3/25.
//
import EssentialFeed
import XCTest

final class FeedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let presentationBundle = Bundle(for: FeedPresenter.self)
        
        assertLocalizedKeyAndValueExist(in: presentationBundle, table)
    }
}

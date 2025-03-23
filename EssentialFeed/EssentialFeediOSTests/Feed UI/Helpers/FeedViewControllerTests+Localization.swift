//
//  FeedViewController+Localization.swift
//  EssentialFeed
//
//  Created by Anthony on 23/3/25.
//
import EssentialFeediOS
import XCTest

extension FeedUIIntegrationTests {
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedViewController.self)
        let value = NSLocalizedString(key, tableName: table, bundle: bundle, value: "Missing localized string for \(key)", comment: "")
        if value == key {
            XCTFail("Missing localized value for key \(key)", file: file, line: line)
        }
        return NSLocalizedString(key, tableName: table, bundle: bundle, value: "Missing localized string for \(key)", comment: "")
    }
}

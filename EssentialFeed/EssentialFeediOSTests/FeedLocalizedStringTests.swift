//
//  FeedLocalizedStringTests.swift
//  EssentialFeed
//
//  Created by Anthony on 3/11/24.
//

import Foundation
import XCTest
import EssentialFeediOS

extension FeedUIIntegrationTests {
    
    func test_feedView_hasTitlte() {
        let (sut, _) = makeSUT()
        
        sut.triggerViewDidLoad()
        
        let bundle = Bundle(for: FeedViewController.self)
        let localizedKey = "FEED_VIEW_TITLE"
        let title = bundle.localizedString(forKey: localizedKey, value: nil, table: localizedTableName)
        
        XCTAssertNotEqual(title, localizedKey, "Missing localized string for key: \(localizedKey)")
        XCTAssertEqual(sut.title, title, "Unexpected title: \(sut.title?.debugDescription ?? "nil") ")
    }
                       
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let presentationBundle = Bundle(for: FeedViewController.self)
        let localizedBundles = allLocalizationBundles(in: presentationBundle)
        let localizedStringKeys = allLocalizedStringKeys(in: localizedBundles, table: table)
        
        localizedBundles.forEach { (bundle, localization) in
            localizedStringKeys.forEach { key in
                let localizedString = bundle.localizedString(forKey: key, value: nil, table: localizedTableName)
                if localizedString == key {
                    let language = Locale.current.localizedString(forLanguageCode: localization) ?? ""
                    
                    XCTFail("Localized string for key: \(key) in bundle: \(bundle) is not localized to \(language)")
                }
            }
        }
    }
}

// MARK: - Helpers
extension FeedUIIntegrationTests {
    
    private typealias LocalizedBundle = (bundle: Bundle, localization: String)
    
    private func allLocalizationBundles(in bundle: Bundle, file: StaticString = #file, line: UInt = #line) -> [LocalizedBundle] {
        return bundle.localizations.compactMap { localization in
            guard
                let path = bundle.path(forResource: localization, ofType: "lproj"),
                let localizedBundle = Bundle(path: path)
            else {
                XCTFail("Couldn't find bundle for localization: \(localization)", file: file, line: line)
                return nil
            }
            
            return (localizedBundle, localization)
        }
    }
    
    private func allLocalizedStringKeys(in bundles: [LocalizedBundle], table: String, file: StaticString = #file, line: UInt = #line) -> Set<String> {
        return bundles.reduce([]) { (acc, current) in
            guard
                let path = current.bundle.path(forResource: table, ofType: "strings"),
                let strings = NSDictionary(contentsOfFile: path),
                let keys = strings.allKeys as? [String]
            else {
                XCTFail("Couldn't load localized strings for localization: \(current.localization)", file: file, line: line)
                return acc
            }
            
            return acc.union(Set(keys))
        }
    }
    
    private var localizedTableName: String {
        "Feed"
    }
}

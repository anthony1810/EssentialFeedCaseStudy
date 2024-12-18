////
////  FeedLocalizedStringTests.swift
////  EssentialFeed
////
////  Created by Anthony on 3/11/24.
////
//
//import Foundation
//import XCTest
//import EssentialFeediOS
//import EssentialFeed
//
//class FeedPresenterLocalizationTests: XCTestCase {
//    
//    func test_feedView_hasTitlte() {
//       let sut = FeedViewController()
//        
//        sut.triggerViewDidLoad()
//        
//        let localizedKey = "FEED_VIEW_TITLE"
//        let title = localized("FEED_VIEW_TITLE")
//        
//        XCTAssertNotEqual(title, localizedKey, "Missing localized string for key: \(localizedKey)")
//        XCTAssertEqual(sut.title, title, "Unexpected title: \(sut.title?.debugDescription ?? "nil") ")
//    }
//                       
//    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
//        let table = "Feed"
//        let presentationBundle = Bundle(for: FeedPresenter.self)
//        assertLocalizationKeyAndValuesExist(in: presentationBundle, table)
//    }
//}
//

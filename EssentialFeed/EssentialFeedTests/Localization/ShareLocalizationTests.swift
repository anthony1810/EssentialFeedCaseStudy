//
//  ShareLocalizationTests.swift
//  EssentialFeed
//
//  Created by Anthony on 7/12/24.
//

import XCTest
import EssentialFeed

class SharedLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizationKeyAndValuesExist(in: bundle, table)
    }

    private class DummyView: ResourceFetchingViewProtocol {
        typealias ViewModel = Any
        
        func display(viewModel: Any) {}
    }
}

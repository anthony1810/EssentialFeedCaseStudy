//
//  SharedLocalizationTests.swift
//  EssentialFeed
//
//  Created by Anthony on 2/8/25.
//

import EssentialFeed
import XCTest

final class SharedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let presentationBundle = Bundle(for: LoadResourcePresenter<Any, DummyResourceView>.self)
        
        assertLocalizedKeyAndValueExist(in: presentationBundle, table)
    }
    
    // MARK: - Helpers
    private class DummyResourceView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
}

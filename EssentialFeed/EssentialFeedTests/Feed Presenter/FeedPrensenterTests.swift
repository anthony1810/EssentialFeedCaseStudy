//
//  FeedPrensenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 5/11/24.
//

import Foundation
import XCTest
import EssentialFeed

class FeedPrensenterTests: XCTestCase {
    func test_map_createViewModel() {
        let feed = uniqueItem().domainModel
        
        let viewModel = FeedPresenter.map([feed])
        
        XCTAssertEqual(viewModel.feeds, [feed])
    }
}

extension FeedPrensenterTests {
    func uniqueItem() -> (domainModel: FeedImage, localModel: LocalFeedImage) {
        let domain = FeedImage(id: UUID(), description: nil, location: nil, imageURL: makeAnyUrl())
        let local = LocalFeedImage(id: domain.id, description: domain.description, location: domain.location, url: domain.imageURL)
        
        return (domain, local)
    }
}

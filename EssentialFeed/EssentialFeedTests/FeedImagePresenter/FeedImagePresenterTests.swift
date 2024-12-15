//
//  FeedImagePresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 6/11/24.
//

import Foundation
import EssentialFeed
import XCTest


final class FeedImagePresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let item = uniqueItem().domainModel
        let viewModel = FeedImagePresenter.map(item)
        
        XCTAssertEqual(viewModel.location, item.location)
        XCTAssertEqual(viewModel.description, item.description)
    }
    
}

extension FeedImagePresenterTests {
    func uniqueItem() -> (domainModel: FeedImage, localModel: LocalFeedImage) {
        let domain = FeedImage(id: UUID(), description: nil, location: nil, imageURL: makeAnyUrl())
        let local = LocalFeedImage(id: domain.id, description: domain.description, location: domain.location, url: domain.imageURL)
        
        return (domain, local)
    }

}

//
//  FeedViewControllerTests+Assertions.swift
//  EssentialFeed
//
//  Created by Anthony on 24/2/25.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import XCTest

extension FeedViewControllerTests {
    func assertThat(
        _ sut: FeedViewController,
        isRendering feeds: [FeedImage],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedFeeds() == feeds.count else {
            XCTFail(
                "Expected \(feeds.count) rendered feeds but \(sut.numberOfRenderedFeeds()) were rendered.",
                file: file,
                line: line
            )
            return
        }
        
        feeds.enumerated().forEach { index, feed in
            assertThat(sut, isRendering: feed, at: index, file: file, line: line)
        }
    }
    
    func assertThat(
        _ sut: FeedViewController,
        isRendering feed: FeedImage,
        at index: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let cell = sut.feedImageView(at: index) else {
            XCTFail("Missing feed cell at index \(index)", file: file, line: line)
            return
        }
        
        let isLocationHidden = feed.location == nil
        
        XCTAssertEqual(
            feed.location,
            cell.locationText,
            "assert that feed location \(String(describing: feed.location)) matches cell location \(String(describing: cell.locationText)) at index = \(index)",
            file: file,
            line: line
        )
        
        XCTAssertEqual(
            feed.description,
            cell.descriptionText,
            "assert that feed description \(String(describing: feed.description)) matches cell description \(String(describing: cell.description)) at index = \(index)",
            file: file,
            line: line)
        
        XCTAssertEqual(
            isLocationHidden,
            !cell.isShowingLocation,
            "assert that feed isLocationHidden \(String(describing: isLocationHidden)) matches cell isShowingLocation \(String(describing: cell.isShowingLocation)) at index = \(index)",
            file: file,
            line: line)
    }
}

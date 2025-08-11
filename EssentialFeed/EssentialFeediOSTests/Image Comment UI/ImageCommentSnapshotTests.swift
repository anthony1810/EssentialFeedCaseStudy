//
//  ImageCommentSnapshotTests.swift
//  EssentialFeed
//
//  Created by Anthony on 10/8/25.
//

import Foundation
import XCTest
@testable import EssentialFeed
import EssentialFeediOS

final class ImageCommentSnapshotTests: XCTestCase {
    func test_renderComments_whenNotEmpty() throws {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iphone8(style: .light)), named: "COMMENT_LIST")
        assert(snapshot: sut.snapshot(for: .iphone8(style: .dark)), named: "COMMENT_LIST_DARK")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComment", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        []
    }
    
    private func errorOccured(_ message: String) -> ResourceErrorViewModel {
        .error(message: message)
    }
    
    private func comments() -> [ImageCommentCellController] {
        [
            ImageCommentCellController(
                viewModel: ImageCommentViewModel(
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    username: "a long long long long username"
                )
            ),
            ImageCommentCellController(
                viewModel: ImageCommentViewModel(
                    message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales..",
                    date: "10 minutes ago",
                    username: "a username"
                )
            ),
            ImageCommentCellController(
                viewModel: ImageCommentViewModel(
                    message: "nice..",
                    date: "10 seconds ago",
                    username: "a name"
                )
            )
        ]
    }
}

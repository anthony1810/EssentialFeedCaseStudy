//
//  FeedSnapshotTests.swift
//  EssentialFeed
//
//  Created by Anthony on 26/7/25.
//
import Foundation
import XCTest
@testable import EssentialFeed
import EssentialFeediOS

final class FeedSnapshotTests: XCTestCase {
    func test_renderFeed_whenNotEmpty() throws {
        let sut = makeSUT()
        
        sut.display(nonEmptyFeed())
        
        assert(snapshot: sut.snapshot(for: .iphone8(style: .light)), named: "NOT_EMPTY_FEED")
        assert(snapshot: sut.snapshot(for: .iphone8(style: .dark)), named: "NOT_EMPTY_FEED_DARK")
    }
    
    func test_renderFeed_whenImageFailedToLoad() throws {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iphone8(style: .light)), named: "IMAGE_FAILED_TO_LOAD")
        assert(snapshot: sut.snapshot(for: .iphone8(style: .dark)), named: "IMAGE_FAILED_TO_LOAD_DARK")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
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
    
    private func nonEmptyFeed() -> [ImageStub] {
        [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(withColor: .systemPink)
            ),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(withColor: .cyan)
            )
        ]
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        [
            ImageStub(
                description: nil,
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: nil
            ),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: nil
            )
        ]
    }
}

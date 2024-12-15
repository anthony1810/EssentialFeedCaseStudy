//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests2
//
//  Created by Anthony on 28/11/24.
//

import XCTest
@testable import EssentialFeed
import EssentialFeediOS

final class FeedSnapshotTests: XCTestCase {
    
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())

        record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_FEED")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_FEED_DARK")
    }
    
    func test_feedWithImages() {
        let sut = makeSUT()
        
        sut.display(feedWithContents())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_DARK")
    }
    
    func test_feedWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "this is an error"))
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_ERROR_MESSAGE")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_ERROR_MESSAGE_DARK")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_DARK")
    }
    
}

class FeedStub: FeedImageDataControllerDelegate {
    let viewModel: FeedImageViewModel
    let image: UIImage?
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?, url: URL) {
        self.image = image
        viewModel = FeedImageViewModel(
            location: location,
            description: description
        )
    }
    
    func didRequestImage() {
        if let image {
            controller?.display(viewModel: image)
            controller?.display(.noError)
        } else {
            controller?.display(LoadResourceErrorViewModel(message: "any"))
        }
    }
    
    func didCancelImageRequest() {
        
    }
}

extension FeedViewController {
    func display(_ cells: [FeedImageCellController]) {
        self.tableModels = cells
    }
    
    func display(_ stubs: [FeedStub]) {
        let cells: [FeedImageCellController] = stubs.map { stub in
            let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub)
            stub.controller = cellController
            
            return cellController
        }
        
        display(cells)
    }
}

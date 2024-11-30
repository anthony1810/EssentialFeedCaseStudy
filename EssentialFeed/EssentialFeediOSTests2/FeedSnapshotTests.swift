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

extension FeedSnapshotTests {
    
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        controller.beginAppearanceTransition(true, animated: false) //view appear again
        controller.endAppearanceTransition()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        []
    }
    
    private func feedWithContents() -> [FeedStub] {
        [
            FeedStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(withColor: .red), url: URL(string: "http://anyurl.com")!
            ),
            FeedStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(withColor: .green), url: URL(string: "http://anyurl.com")!
            )
        ]
    }
    
    private func feedWithFailedImageLoading() -> [FeedStub] {
        [
            FeedStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: nil,
                url: URL(string: "http://anyurl.com")!
            ),
            FeedStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: nil,
                url: URL(string: "http://anyurl.com")!
            )
        ]
    }
    
    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = makeSnapshotData(snapshot: snapshot)
        let snapshotURL = makeSnapshotURL(named: name)
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot: \(error)", file: file, line: line)
        }
    }
    
    private func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = makeSnapshotData(snapshot: snapshot)
        let snapshotURL = makeSnapshotURL(named: name)
        
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load snapshot at \(snapshotURL), record snapshot before asserting.", file: file, line: line)
            return
        }
        
        if storedSnapshotData != snapshotData {
            let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: tempDir)
            
            XCTFail("Stored Snapshot mismatch at \(snapshotURL). New Recorded snapshot: \(tempDir).", file: file, line: line)
        }
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString = #file, line: UInt = #line) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func makeSnapshotData(snapshot: UIImage, file: StaticString = #file, line: UInt = #line) -> Data? {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate png data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return snapshotData
    }
}

class FeedStub: FeedImageDataControllerDelegate {
    let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?, url: URL) {
        viewModel = FeedImageViewModel(location: location, description: description, url: url, image: image, isLoading: false, shouldRetry: image == nil)
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
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
            let cellController = FeedImageCellController(delegate: stub)
            stub.controller = cellController
            
            return cellController
        }
        
        display(cells)
    }
}

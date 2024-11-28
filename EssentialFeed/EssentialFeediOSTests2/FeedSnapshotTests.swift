//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests2
//
//  Created by Anthony on 28/11/24.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedSnapshotTests: XCTestCase {
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())

        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
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
        
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        []
    }
    
    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate png data representation from snapshot", file: file, line: line)
            return
        }
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot: \(error)", file: file, line: line)
        }
    }
}

extension FeedViewController {
    func display(_ cells: [FeedImageCellController]) {
        self.tableModels = cells
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}

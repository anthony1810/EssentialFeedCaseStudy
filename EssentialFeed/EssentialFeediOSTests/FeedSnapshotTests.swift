//
//  FeedSnapshotTests.swift
//  EssentialFeed
//
//  Created by Anthony on 26/7/25.
//
import Foundation
import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedSnapshotTests: XCTestCase {
    func test_renderFeed_whenEmpty() throws {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        []
    }
    
    private func record(
        snapshot: UIImage,
        named: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG representation from snapshot", file: file, line: line)
            return
        }
        
        let snapshotURL = URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent(named + ".png")
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
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


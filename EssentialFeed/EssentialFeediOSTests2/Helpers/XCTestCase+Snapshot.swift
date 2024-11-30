//
//  XCTestCase+Snapshot.swift
//  EssentialFeed
//
//  Created by Anthony on 30/11/24.
//
import XCTest
@testable import EssentialFeed
import EssentialFeediOS

extension XCTestCase {
    
    func makeSUT() -> FeedViewController {
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
    
    func emptyFeed() -> [FeedImageCellController] {
        []
    }
    
    func feedWithContents() -> [FeedStub] {
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
    
    func feedWithFailedImageLoading() -> [FeedStub] {
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
    
    func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = makeSnapshotData(snapshot: snapshot)
        let snapshotURL = makeSnapshotURL(named: name)
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot: \(error)", file: file, line: line)
        }
    }
    
    func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
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
    
    func makeSnapshotURL(named name: String, file: StaticString = #file, line: UInt = #line) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    func makeSnapshotData(snapshot: UIImage, file: StaticString = #file, line: UInt = #line) -> Data? {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate png data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return snapshotData
    }
}

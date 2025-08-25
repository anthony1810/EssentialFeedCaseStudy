//
//  XCTestCase+Snapshot.swift
//  EssentialFeed
//
//  Created by Anthony on 26/7/25.
//

import UIKit
import XCTest

extension XCTestCase {
    func record(
        snapshot: UIImage,
        named: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let snapshotData = makeSnapshotData(image: snapshot, file: file, line: line)
        let snapshotURL = makeSnapshotURL(named: named, file: file, line: line)
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try snapshotData?.write(to: snapshotURL)
            XCTFail("Record Success, use `assert` to check snapshot`", file: file, line: line)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }

    func assert(
        snapshot: UIImage,
        named: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let snapshotData = makeSnapshotData(image: snapshot, file: file, line: line)
        let snapshotURL = makeSnapshotURL(named: named, file: file, line: line)
        let storedSnapshotData = loadSnapshot(from: snapshotURL, file: file, line: line)
        
        if snapshotData != storedSnapshotData {
            let tempPath = URL(filePath: NSTemporaryDirectory())
                .appendingPathComponent(snapshotURL.lastPathComponent + ".png")
            
            try? snapshotData?.write(to: tempPath)
            
            XCTFail("New snapshot does not match stored snapshot, new snapshot saved at \(tempPath)", file: file, line: line)
        }
    }

    func makeSnapshotURL(named: String, file: StaticString = #file, line: UInt = #line) -> URL {
        let snapshotURL = URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent(named + ".png")
        
        return snapshotURL
    }

    func makeSnapshotData(image: UIImage, file: StaticString = #file, line: UInt = #line) -> Data? {
        guard let pngRepresentation = image.pngData() else {
            XCTFail("Failed to convert image to PNG data", file: file, line: line)
            return nil
        }
        
        return pngRepresentation
    }

    func loadSnapshot(from url: URL, file: StaticString = #file, line: UInt = #line) -> Data? {
        guard let storedSnapshotData = try? Data(NSData(contentsOf: url)) else {
            XCTFail("Failed to load snapshot at \(url). Use `record` to record first", file: file, line: line)
            return nil
        }
        
        return storedSnapshotData
    }
}


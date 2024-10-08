//
//  XCTestCase+MemoryLeak.swift
//  EssentialFeed
//
//  Created by Anthony on 9/10/24.
//
import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leaks", file: file, line: line)
        }
    }
}


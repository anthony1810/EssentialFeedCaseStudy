//
//  XCTestCase+MemoryLeak.swift
//  EssentialFeed
//
//  Created by Anthony on 26/1/25.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential memory leak", file: file, line: line)
        }
    }
}

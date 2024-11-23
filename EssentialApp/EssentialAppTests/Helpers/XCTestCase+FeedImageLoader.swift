//
//  XCTestCase+FeedImageLoader.swift
//  EssentialApp
//
//  Created by Anthony on 23/11/24.
//

import Foundation
import XCTest
import EssentialFeed
import EssentialApp

protocol FeedImageDataLoaderTest: XCTestCase {}

extension FeedImageDataLoaderTest {
    func expect(sut: FeedImageDataLoaderProtocol, toLoad url: URL, with expectedResult: FeedImageDataLoaderProtocol.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load")
        _ = sut.loadImageData(from: url, completion: { actualResult in
            switch (actualResult, expectedResult) {
            case let (.success(actualData), .success(expectedData)):
                XCTAssertEqual(actualData, expectedData, file: file, line: line)
            case let (.failure(actualError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(actualError, expectedError)
            default:
                XCTFail("Expect \(expectedResult), but got \(actualResult) instead")
            }
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

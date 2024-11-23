//
//  FeedLoaderTestCase.swift
//  EssentialApp
//
//  Created by Anthony on 23/11/24.
//
import EssentialFeed
import XCTest

protocol FeedLoaderTestCase: XCTestCase {}

extension FeedLoaderTestCase {
    func expect(sut: FeedLoaderProtocol, toFinishWith expectedResult: FeedLoaderProtocol.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for load")
        sut.load { actualResult in
            switch (actualResult, expectedResult) {
            case let (.success(actualFeeds), .success(expectedFeeds)):
                XCTAssertEqual(actualFeeds, expectedFeeds, file: file, line: line)
            case let (.failure(actualError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(actualError, expectedError, file: file, line: line)
            default:
                XCTFail("Expect \(expectedResult), got \(actualResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

//
//  XCTestCase+Extensions.swift
//  EssentialApp
//
//  Created by Anthony on 21/11/24.
//

import Foundation
import XCTest
import EssentialFeed

extension XCTestCase {
    func makeAnyError() -> NSError {
        NSError(domain: "any error", code: Int.random(in: 0..<Int.max), userInfo: nil)
    }
    
    func makeAnyUrl() -> URL {
        URL(string: "https://any-url.com\(Int.random(in: 0..<Int.max))")!
    }
    
    func makeAnyData() -> Data {
        Data("anydata".utf8)
    }
    
    func makeAnyURLResponse() -> URLResponse {
        URLResponse(url: makeAnyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func makeAnyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: makeAnyUrl(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leaks", file: file, line: line)
        }
    }
    
    func uniqueItem() -> (domainModel: FeedImage, localModel: LocalFeedImage) {
        let domain = FeedImage(id: UUID(), description: nil, location: nil, imageURL: makeAnyUrl())
        let local = LocalFeedImage(id: domain.id, description: domain.description, location: domain.location, url: domain.imageURL)
        
        return (domain, local)
    }
}

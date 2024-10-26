//
//  XCTestCase+Any.swift
//  EssentialFeed
//
//  Created by Anthony on 12/10/24.
//
import Foundation
import XCTest

extension XCTestCase {
    func makeAnyError() -> NSError {
        NSError(domain: "any error", code: 1, userInfo: nil)
    }
    
    func makeAnyUrl() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    func makeAnyURLResponse() -> URLResponse {
        URLResponse(url: makeAnyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func makeAnyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: makeAnyUrl(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
}

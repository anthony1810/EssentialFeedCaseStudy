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
}

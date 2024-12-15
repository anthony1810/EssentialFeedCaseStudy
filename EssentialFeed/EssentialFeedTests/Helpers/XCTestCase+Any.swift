//
//  XCTestCase+Any.swift
//  EssentialFeed
//
//  Created by Anthony on 12/10/24.
//
import Foundation
import XCTest

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

func makeAnyHTTPURLResponse(statusCode: Int = 200) -> HTTPURLResponse {
    HTTPURLResponse(url: makeAnyUrl(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
}

extension Date {
    func addingSeconds(_ seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }

    func addingDay(_ day: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: day, to: self)!
    }

    func addingMinutes(_ minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}

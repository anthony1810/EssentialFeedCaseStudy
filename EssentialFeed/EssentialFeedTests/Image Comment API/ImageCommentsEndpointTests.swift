//
//  ImageCommentsEndpointTests.swift
//  EssentialApp
//
//  Created by Anthony on 25/8/25.
//
import Foundation
import XCTest
import EssentialFeed

final class ImageCommentsEndpointTests: XCTestCase {
    func test_imageComments_endpointURL() {
        let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
        let feedImageId = UUID()
        
        let received = ImageCommentsEndpoint.get(feedImageId).url(baseURL: baseURL)
        let expected = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/\(feedImageId)/comments")!
        
        XCTAssertEqual(received, expected)
    }
}

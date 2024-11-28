//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Anthony on 27/11/24.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() throws {
        let store = InMemoryFeedStore()
        let httpClient = HTTPClientStub.online(response)
        
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        let feedVC = nav?.topViewController as! FeedViewController
        
        XCTAssertEqual(feedVC.numberOfRenderedFeedImageViews(), 2)
        XCTAssertNotNil(feedVC.stimulateVisibleView(at: 0).renderedImage)
        XCTAssertNotNil(feedVC.stimulateVisibleView(at: 1).renderedImage)
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() throws {
        
    }
    
    func test_onLaunch_displayEmptyFeedsOnNoCachedAndNoConnectivity() throws {
        
    }
}

extension FeedAcceptanceTests {
    
    private func response(url: URL) -> (HTTPURLResponse, Data) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, makeData(for: url))
    }
    
    func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            "items": [
                ["id": UUID().uuidString, "image": "http://image.com"],
                ["id": UUID().uuidString, "image": "http://image.com"]
            ]
        ])
    }
}

private class HTTPClientStub: HTTPClient {
    
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    private let stub: (URL) -> HTTPClient.Result

    init(stub: @escaping (URL) -> HTTPClient.Result) {
        self.stub = stub
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(stub(url))
        
        return Task()
    }
    
    static var offline: HTTPClientStub {
        HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0, userInfo: nil))})
    }
    
    static func online(_ stub: @escaping (URL) -> (HTTPURLResponse, Data)) -> HTTPClientStub {
        HTTPClientStub(stub: { url in
                .success(stub(url))
        })
    }
}

private class InMemoryFeedStore: FeedStoreProtocol {
        
    private var feedCache: Cache?
    private var feedImageDataCache: [URL: Data] = [:]
    
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
    
    func deleteCache(completion: @escaping DeletionCacheCompletion) {
        feedCache = nil
        completion(nil)
    }
    
    func insertCache(_ items: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCacheCompletion) {
        feedCache = .found(items, timestamp)
        completion(nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
      if let feedCache {
          completion(.success(feedCache))
        } else {
            completion(.success(.empty))
        }
    }
}

extension InMemoryFeedStore: LocalFeedImageStoreProtocol {
    func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(feedImageDataCache[url]))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        feedImageDataCache[url] = data
        completion(.success(data))
    }
}



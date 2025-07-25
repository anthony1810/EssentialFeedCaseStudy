//
//  FeedAcceptanceTests.swift
//  EssentialApp
//
//  Created by Anthony on 24/7/25.
//
import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let sut = launch(httpClient: .online(response))
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(sut.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(sut.renderedFeedImageData(at: 1), makeImageData())
    }
    
    func test_onLauch_displaysLocalFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryStore.empty
        let online = launch(httpClient: .online(response), store: sharedStore)
        online.simulateAppearance()
        online.simulateFeedImageViewVisible(at: 0)
        online.simulateFeedImageViewVisible(at: 1)
        
        let offline = launch(httpClient: .offline, store: sharedStore)
        offline.simulateAppearance()
        
        XCTAssertEqual(offline.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(offline.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(offline.renderedFeedImageData(at: 1), makeImageData())
    }
    
    func test_onLauch_displayEmptyFeedWhenCustomerHasNoConnectivityAndNoLocalFeed() {
        let offline = launch(httpClient: .offline, store: .empty)
        offline.simulateAppearance()
        
        XCTAssertEqual(offline.numberOfRenderedFeedImageViews(), 0)
    }
    
    // MARK: - Helpers
    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryStore = .empty
    ) -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        guard let nav = sut.window?.rootViewController as? UINavigationController else {
            fatalError("Root view is not a UINavigationController")
        }
        guard let vc = nav.topViewController as? FeedViewController else {
            fatalError("Top view controller is not a FeedViewController")
        }
        
        return vc
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
            .init(stub: { _ in
                    .failure(URLError(.notConnectedToInternet))
            })
        }
        
        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub { url in .success(stub(url))}
        }
    }
    
    private class InMemoryStore: FeedImageDataStore & FeedStore {
        
        private var cacheFeed: CacheFeed?
        private var feedImageDataCache: [URL: Data] = [:]
        
        static var empty: InMemoryStore {
            .init()
        }
        
        // MARK: - FeedStore
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            cacheFeed = nil
            completion(.success(()))
        }
        
        func insertCachedFeed(_ items: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
            cacheFeed = CacheFeed(feed: items, timestamp: timestamp)
            completion(.success(()))
        }
        
        func retrievalCachedFeed(completion: @escaping RetrievalCompletion) {
            completion(.success(cacheFeed))
        }
        
        // MARK: - FeedImageDataStore
        func retrieve(dataForURL url: URL, completion: @escaping (Result<Data?, any Error>) -> Void) {
            completion(.success(feedImageDataCache[url]))
        }
        
        func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            feedImageDataCache[url] = data
            completion(.success(()))
        }
    }
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
            fatalError("response error")
        }
        let data = makeData(for: url)
        
        return (data, response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            "items" : [
                ["id": UUID().uuidString, "image": "http://image.com"],
                ["id": UUID().uuidString, "image": "http://image.com"]
            ]
        ])
    }
    
    private func makeImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }
}

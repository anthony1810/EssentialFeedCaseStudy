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
    
    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryStore.expiredCacheFeed
        enteringBackground(with: store)
        
        XCTAssertTrue(store.cacheFeed == nil)
    }
    
    func test_onEnteringForeground_keepsNonExpiredFeedCache() {
        let store = InMemoryStore.nonExpiredCacheFeed
        enteringBackground(with: store)
        
        XCTAssertTrue(store.cacheFeed != nil)
    }
    
    // MARK: - Helpers
    private func enteringBackground(with store: InMemoryStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryStore = .empty
    ) -> ListViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        guard let nav = sut.window?.rootViewController as? UINavigationController else {
            fatalError("Root view is not a UINavigationController")
        }
        guard let vc = nav.topViewController as? ListViewController else {
            fatalError("Top view controller is not a FeedViewController")
        }
        
        return vc
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

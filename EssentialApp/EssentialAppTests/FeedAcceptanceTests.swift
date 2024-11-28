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
        let store = InMemoryFeedStore.empty
        let httpClient = HTTPClientStub.online(response)
        
        let feedVC = launch(httpClient: httpClient, store: store)
        feedVC.triggerViewWillAppear()
        
        XCTAssertEqual(feedVC.numberOfRenderedFeedImageViews(), 2)
        XCTAssertNotNil(feedVC.stimulateVisibleView(at: 0).renderedImage)
        XCTAssertNotNil(feedVC.stimulateVisibleView(at: 1).renderedImage)
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() throws {
        let shareStore = InMemoryFeedStore.empty
        let httpClient = HTTPClientStub.online(response)
        
        let onlineFeedVC = launch(httpClient: httpClient, store: shareStore)
        onlineFeedVC.triggerViewWillAppear()
        onlineFeedVC.stimulateVisibleView(at: 0)
        onlineFeedVC.stimulateVisibleView(at: 1)
        
        let offlineFeedVC = launch(httpClient: HTTPClientStub.offline, store: shareStore)
        offlineFeedVC.triggerViewWillAppear()
        
        XCTAssertEqual(offlineFeedVC.numberOfRenderedFeedImageViews(), 2)
        XCTAssertNotNil(offlineFeedVC.stimulateVisibleView(at: 0).renderedImage)
        XCTAssertNotNil(offlineFeedVC.stimulateVisibleView(at: 1).renderedImage)
    }
    
    func test_onLaunch_displayEmptyFeedsOnNoCachedAndNoConnectivity() throws {
        let feedVC = launch(httpClient: HTTPClientStub.offline, store: InMemoryFeedStore.empty)
        feedVC.triggerViewWillAppear()
        
        XCTAssertEqual(feedVC.numberOfRenderedFeedImageViews(), 0)
    }
    
    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryFeedStore.expired
        
        enteringBackground(with: store)
        
        XCTAssertNil(store.feedCache, "Expected to delete expired cache")
    }
    
    func test_onEnteringBackground_KeepNonExpiredFeedImageCache() {
        let store = InMemoryFeedStore.nonExpired
        
        enteringBackground(with: store)
        
        XCTAssertNotNil(store.feedCache, "Expected to delete expired cache")
    }
}

extension FeedAcceptanceTests {
    
    private func launch(httpClient: HTTPClient, store: FeedStoreProtocol & LocalFeedImageStoreProtocol) -> FeedViewController {
        
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        let feedVC = nav?.topViewController as! FeedViewController
        
        return feedVC
    }
    
    private func enteringBackground(with store: FeedStoreProtocol & LocalFeedImageStoreProtocol) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
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




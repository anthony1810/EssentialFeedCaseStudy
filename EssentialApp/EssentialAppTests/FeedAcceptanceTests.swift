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
        XCTAssertEqual(sut.renderedFeedImageData(at: 0), makeImageData01())
        XCTAssertEqual(sut.renderedFeedImageData(at: 1), makeImageData02())
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
        XCTAssertEqual(offline.renderedFeedImageData(at: 0), makeImageData01())
        XCTAssertEqual(offline.renderedFeedImageData(at: 1), makeImageData02())
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
    
    func test_onFeedImageSelection_displayComments() {
        let feed = showCommentsForFirstImage()
        
        XCTAssertEqual(feed.numberOfRenderedCommentsViews(), 1)
        XCTAssertEqual(feed.commentMessage(at: 0), makeCommentMessage())
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
        
        vc.simulateAppearance()
        
        return vc
    }
    
    private func showCommentsForFirstImage() -> ListViewController {
        let feed = launch(httpClient: .online(response))
        feed.simulateAppearance()
        
        feed.simulateFeedImageTap(at: 0)
        
        RunLoop.current.run(until: Date())
        
        let nav = feed.navigationController
        guard let vc = nav?.topViewController as? ListViewController else {
            fatalError("Top view controller is not a FeedViewController")
        }
        vc.simulateAppearance()
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
        switch url.path {
        case "/image-1":
            return makeImageData01()
        case "/image-2":
            return makeImageData02()
        case "/essential-feed/v1/image/\(makeFirstImageID())/comments":
            return makeCommentsData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            "items" : [
                ["id": makeFirstImageID(), "image": "http://image.com/image-1"],
                ["id": UUID().uuidString, "image": "http://image.com/image-2"]
            ]
        ])
    }
    
    private func makeCommentsData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            "items" : [
                [
                    "id": UUID().uuidString,
                    "message": makeCommentMessage(),
                    "created_at": "2020-05-20T11:24:59+0000",
                    "author": [
                        "username": "a user name"
                    ]
                ]
            ]
        ])
    }
    
    private func makeImageData01() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }
    private func makeImageData02() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeFirstImageID() -> String {
        "A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A"
    }
    
    private func makeCommentMessage() -> String {
        "any comment message"
    }
}

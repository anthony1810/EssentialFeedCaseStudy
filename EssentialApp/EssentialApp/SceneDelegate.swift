//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Anthony on 6/7/25.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        return client
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        let storeURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("EssentialFeed.sqlite")
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        
        return store
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        
        self.httpClient = httpClient
        self.store = store
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    
    func configureWindow() {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: httpClient)
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        
        // Feed
        let feedLoader = FeedLoaderWithFallbackComposite(
            primaryLoader: FeedLoaderCacheDecorator(
                decoratee: remoteFeedLoader,
                cache: localFeedLoader
            ),
            fallbackLoader: localFeedLoader
        )
        
        // Feed Image
        let remoteFeedImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localFeedImageLoader = LocalFeedImageDataLoader(store: store)
        let feedImageLoader = FeedImageLoaderWithFallbackComposite(
            primary: FeedImageLoaderCacheDecorater(
                decoratee: remoteFeedImageLoader,
                cache: localFeedImageLoader
            ),
            fallback: localFeedImageLoader
        )
        
        let feedVC = FeedUIComposer.feedComposedWith(
            feedLoader: feedLoader,
            imageLoader: feedImageLoader
        )
        
        window?.rootViewController = UINavigationController(rootViewController: feedVC)
    }
}


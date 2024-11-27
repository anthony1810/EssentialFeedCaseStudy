//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Anthony on 20/11/24.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import RealmSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let realmConfig = Realm.Configuration.defaultConfiguration

    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    
    func configureWindow() {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        // Remote
        let client = makeHTTPClient()
        let remoteFeedImageDataLoader = RemoteFeedImageDataLoader(client: client)
        let remoteFeedLoader = RemoteFeedLoader(httpClient: client, url: url)
        
        // Local
        let feedStore = RealmFeedStore(realmConfig: realmConfig)
        let localFeedLoader = LocalFeedLoader(store: feedStore, timestamp: Date.init)
        let localFeedImageDataLoader = LocalFeedImageDataLoader(store: feedStore)
        
    
        // Decorator RemoteLoad with localCache
        let remoteFeedLoaderWithLocalCache = FeedLoaderCacheDecorator(
            decoratee: remoteFeedLoader,
            cache: localFeedLoader
        )
        let remoteFeedImageDataLoaderWithLocalCache = FeedImageDataLoaderDecorator(
            decoratee: remoteFeedImageDataLoader,
            cache: localFeedImageDataLoader
        )
        
        //composite
        let feedLoaderWithFallBack = FeedLoaderWithFallbackComposite(
            primary: remoteFeedLoaderWithLocalCache,
            fallback: localFeedLoader
        )
        
        let feedImageDataLoaderWithFallback = FeedImageDataLoaderWithFallbackComposite(
            primary: remoteFeedImageDataLoaderWithLocalCache,
            fallback: localFeedImageDataLoader
        )
        
        let feedVC = FeedUIComposer.composeFeedViewController(
            loader: feedLoaderWithFallBack,
            imageLoader: feedImageDataLoaderWithFallback
        )
        
        window?.rootViewController = UINavigationController(rootViewController: feedVC)
    }

    func makeHTTPClient() -> HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }

}

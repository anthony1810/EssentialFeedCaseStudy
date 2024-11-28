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
   
    lazy var feedStore: FeedStoreProtocol & LocalFeedImageStoreProtocol = {
        let store = RealmFeedStore(realmConfig: Realm.Configuration.defaultConfiguration)
        return store
    }()
    
    lazy var httpClient: HTTPClient = {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        return client
    }()
    
    lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: feedStore, timestamp: Date.init)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStoreProtocol & LocalFeedImageStoreProtocol) {
        self.init()
        
        self.httpClient = httpClient
        self.feedStore = store
    }

    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    
    func configureWindow() {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        // Remote
        let remoteFeedImageDataLoader = RemoteFeedImageDataLoader(client: httpClient)
        let remoteFeedLoader = RemoteFeedLoader(httpClient: httpClient, url: url)
        
        // Local
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
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache(completion: { _ in })
    }
}

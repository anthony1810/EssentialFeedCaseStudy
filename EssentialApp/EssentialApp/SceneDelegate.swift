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
import Combine

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
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }
    
    func configureWindow() {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        // Remote
        let remoteFeedImageDataLoader = RemoteFeedImageDataLoader(client: httpClient)
        let remoteFeedLoader = RemoteFeedLoader(httpClient: httpClient, url: url)
        
        // Local
        let localFeedImageDataLoader = LocalFeedImageDataLoader(store: feedStore)
        
        let remoteFeedImageDataLoaderWithLocalCache = FeedImageDataLoaderDecorator(
            decoratee: remoteFeedImageDataLoader,
            cache: localFeedImageDataLoader
        )
        
        let feedImageDataLoaderWithFallback = FeedImageDataLoaderWithFallbackComposite(
            primary: remoteFeedImageDataLoaderWithLocalCache,
            fallback: localFeedImageDataLoader
        )
        
        let combineLoader = makeCombineRemoteFeedLoaderWithLocalFallback(
            remoteFeedLoader: remoteFeedLoader,
            localFeedCache: localFeedLoader,
            localFeedLoader: localFeedLoader
        )
        let feedVC = FeedUIComposer.composeFeedViewController(combineLoader: { combineLoader }, imageLoader: feedImageDataLoaderWithFallback)
        
        window?.rootViewController = UINavigationController(rootViewController: feedVC)
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache(completion: { _ in })
    }
    
    // MARK: - Combine
    private func makeCombineRemoteFeedLoaderWithLocalFallback(
        remoteFeedLoader: FeedLoaderProtocol,
        localFeedCache: FeedCacheProtocol,
        localFeedLoader: FeedLoaderProtocol
    ) -> FeedLoaderProtocol.Publisher {
      
        return remoteFeedLoader
            .loadPublisher()
            .cache(to: localFeedCache)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    // MARK: - Closure-based
    private func makeClosuredBaseRemoteFeedLoaderWithLocalFallback(
        remoteFeedLoader: FeedLoaderProtocol,
        localFeedCache: FeedCacheProtocol,
        localFeedLoader: FeedLoaderProtocol
    ) -> FeedLoaderProtocol {
        
        // Decorator RemoteLoad with localCache
        let remoteFeedLoaderWithLocalCache = FeedLoaderCacheDecorator(
            decoratee: remoteFeedLoader,
            cache: localFeedCache
        )
        
        // Composite RemoteLoader with fallback of local loader
        let feedLoaderWithFallBack = FeedLoaderWithFallbackComposite(
            primary: remoteFeedLoaderWithLocalCache,
            fallback: localFeedLoader
        )
        
        return feedLoaderWithFallBack
    }
}

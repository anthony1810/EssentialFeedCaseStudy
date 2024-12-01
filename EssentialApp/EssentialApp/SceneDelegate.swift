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
        
//        let feedVC = FeedUIComposer.composeFeedViewController(
//            loader: feedLoaderWithFallBack,
//            imageLoader: feedImageDataLoaderWithFallback
//        )
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
}

// combine remote feed loader
public extension FeedLoaderProtocol {
    typealias Publisher = AnyPublisher<[FeedImage], Error>
    func loadPublisher() -> Publisher {
        Deferred {
            Future { promise in
                self.load { result in
                    switch result {
                    case .success(let feeds):
                        return promise(.success(feeds))
                    case .failure(let error):
                        return promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// combine remote feed loader with caching
public extension Publisher where Output == [FeedImage] {
    func cache(to cacher: FeedCacheProtocol) -> AnyPublisher<Output, Failure> {
        self.handleEvents(receiveOutput: cacher.saveCacheIgnoreCompletion).eraseToAnyPublisher()
    }
}

// combine composite feedloader with fallback
public extension Publisher where Output == [FeedImage] {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

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
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }
    
    func configureWindow() {
        let feedVC = makeFeedViewController()
        
        window?.rootViewController = UINavigationController(rootViewController: feedVC)
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache(completion: { _ in })
    }
    
    private func makeFeedViewController() -> ListViewController {
        return FeedUIComposer.composeFeedViewController(
            combineLoader: makeCombineRemoteFeedLoaderWithLocalFallback,
            combineImageLoader: makeCombineRemoteFeedImageDataLoaderWithLocalFallback
        )
    }
}

// MARK: - Combine
extension SceneDelegate {
    private func makeCombineRemoteFeedLoaderWithLocalFallback() -> FeedLoaderProtocol.Publisher {
        
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        return httpClient
            .getPublisher(url: url)
            .tryMap(FeedItemsMapper.map)
            .cache(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeCombineRemoteFeedImageDataLoaderWithLocalFallback(
        url: URL
    ) -> FeedImageDataLoaderProtocol.Publisher {
      
        let localFeedImageDataLoader = LocalFeedImageDataLoader(store: feedStore)
        
        return localFeedImageDataLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: { [httpClient] in
                httpClient
                    .getPublisher(url: url)
                    .tryMap(FeedImageDataMapper.map)
                    .cache(to: localFeedImageDataLoader, with: url)
            })
    }
}

// MARK: - Closure-based
extension SceneDelegate {
    private func makeClosuredBaseRemoteFeedLoaderWithLocalFallback() -> FeedLoaderProtocol {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        let remoteFeedLoader = RemoteLoader(httpClient: httpClient, url: url, mapper: FeedItemsMapper.map)
        
        // Decorator RemoteLoad with localCache
        let remoteFeedLoaderWithLocalCache = FeedLoaderCacheDecorator(
            decoratee: remoteFeedLoader,
            cache: localFeedLoader
        )
        
        // Composite RemoteLoader with fallback of local loader
        let feedLoaderWithFallBack = FeedLoaderWithFallbackComposite(
            primary: remoteFeedLoaderWithLocalCache,
            fallback: localFeedLoader
        )
        
        return feedLoaderWithFallBack
    }
    
    private func makeClosuredBaseRemoteFeedImageDataLoaderWithLocalFallback() -> FeedImageDataLoaderProtocol {
        let remoteFeedImageDataLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localFeedImageDataLoader = LocalFeedImageDataLoader(store: feedStore)
        
        let remoteFeedImageDataLoaderWithLocalCache = FeedImageDataLoaderDecorator(
            decoratee: remoteFeedImageDataLoader,
            cache: localFeedImageDataLoader
        )
        
        let feedImageDataLoaderWithFallback = FeedImageDataLoaderWithFallbackComposite(
            primary: remoteFeedImageDataLoaderWithLocalCache,
            fallback: localFeedImageDataLoader
        )
        
        return feedImageDataLoaderWithFallback
    }
        
}

extension RemoteLoader: @retroactive FeedLoaderProtocol where Resource == [FeedImage] {}

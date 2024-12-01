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
        let feedVC = FeedUIComposer.composeFeedViewController(
            combineLoader: makeCombineRemoteFeedLoaderWithLocalFallback,
            combineImageLoader: makeCombineRemoteFeedImageDataLoaderWithLocalFallback
        )
        
        window?.rootViewController = UINavigationController(rootViewController: feedVC)
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache(completion: { _ in })
    }
    
    // MARK: - Combine
    private func makeCombineRemoteFeedLoaderWithLocalFallback() -> FeedLoaderProtocol.Publisher {
        
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let remoteFeedLoader = RemoteFeedLoader(httpClient: httpClient, url: url)
        
        return remoteFeedLoader
            .loadPublisher()
            .cache(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeCombineRemoteFeedImageDataLoaderWithLocalFallback(
        url: URL
    ) -> FeedImageDataLoaderProtocol.Publisher {
        let remoteFeedImageDataLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localFeedImageDataLoader = LocalFeedImageDataLoader(store: feedStore)
        
        return localFeedImageDataLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteFeedImageDataLoader.loadImageDataPublisher(from: url)
                    .cache(to: localFeedImageDataLoader, with: url) }
            )
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

public extension FeedImageDataLoaderProtocol {
    typealias Publisher = AnyPublisher<Data?, Error>
    
    func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: ImageLoadingDataTaskProtocol?
        return Deferred {
            Future { promise in
                task = self.loadImageData(from: url, completion: promise)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

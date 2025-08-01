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
import Combine

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
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var remoteFeedLoader: RemoteLoader<[FeedImage]> = {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let remoteFeedLoader = RemoteLoader<[FeedImage]>(url: url, client: httpClient, mapper: FeedMapper.map)
        return remoteFeedLoader
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        
        self.httpClient = httpClient
        self.store = store
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validate { _ in }
    }
    
    func configureWindow() {
        let feedVC = FeedUIComposer.feedComposedWith(
            feedLoaderPublisher: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeRemoteFeedImageDataLoaderWithLocalFallback
        )
        
        window?.rootViewController = UINavigationController(rootViewController: feedVC)
        
        window?.makeKeyAndVisible()
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error> {
        remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeRemoteFeedImageDataLoaderWithLocalFallback(url: URL) -> RemoteFeedImageDataLoader.Publisher {
        let remoteFeedImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localFeedImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localFeedImageLoader
            .loadPublisher(from: url)
            .fallback {
                remoteFeedImageLoader.loadPublisher(from: url)
                    .caching(to: localFeedImageLoader, using: url)
            }
    }
}

extension RemoteLoader: FeedLoader where T == [FeedImage] {}


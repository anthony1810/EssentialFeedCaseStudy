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
    
    private lazy var remoteURL: URL = {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        return url
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
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
        httpClient
            .getPublisher(for: remoteURL)
            .tryMap(FeedMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeRemoteFeedImageDataLoaderWithLocalFallback(url: URL) -> AnyPublisher<Data, Error> {
        let localFeedImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localFeedImageLoader
            .loadPublisher(from: url)
            .fallback { [httpClient] in
                httpClient
                    .getPublisher(for: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localFeedImageLoader, using: url)
            }
    }
}


//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Anthony on 6/7/25.
//

import UIKit
import CoreData
import Combine
import os

import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private lazy var logger = Logger(subsystem: "com.example.EssentialApp", category: "main")
    
    private lazy var httpClient: HTTPClient = {
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        return client
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            let storeURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("EssentialFeed.sqlite")
            
            return try CoreDataFeedStore(storeURL: storeURL)
        } catch {
            assertionFailure("Failed to instantiate CoreData Store with error: \(error.localizedDescription)")
            
            logger.fault("Failed to instantiate CoreData Store with error: \(error.localizedDescription)")
            
            return NullStore()
        }
    }()
    
    private static var baseURL: URL = {
        URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    }()
    
    private lazy var remoteURL: URL = {
        FeedEndpoint.get().url(baseURL: Self.baseURL)
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var feedNavigationController: UINavigationController = {
        let feedVC = FeedUIComposer.feedComposedWith(
            feedLoaderPublisher: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeRemoteFeedImageDataLoaderWithLocalFallback,
            selectImageHandler: showComments
        )
        
        let nc = UINavigationController(rootViewController: feedVC)
        
        return nc
    }()
    
    private lazy var scheduler: any Scheduler = DispatchQueue(
        label: "com.viothun.infra.queue",
        qos: .userInteractive,
        attributes: .concurrent
    )
    
    convenience init(
        httpClient: HTTPClient,
        store: FeedStore & FeedImageDataStore,
        scheduler: any Scheduler
    ) {
        self.init()
        
        self.httpClient = httpClient
        self.store = store
        self.scheduler = scheduler
    }
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        do {
            try localFeedLoader.validate()
        } catch {
            logger.log("Failed to validate cache with error: \(error.localizedDescription)")
        }
    }
    
    func configureWindow() {
        window?.rootViewController = feedNavigationController
        
        window?.makeKeyAndVisible()
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
       makeRemoteFeedLoader()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .subscribe(onSome: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(oldItems: items, last: items.last)
    }
    
    private func makePage(oldItems: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
        .init(
            items: oldItems,
            loadMorePublisher: last.map { lastImage in
                { self.makeRemoteLoadMoreLoader(last: lastImage) }
            }
        )
    }
    
    private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
        let url = FeedEndpoint.get(after: after?.id).url(baseURL: Self.baseURL)
        
        return httpClient
            .getPublisher(for: url)
            .tryMap(FeedMapper.map)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, any Error> {
        return localFeedLoader.loadPublisher()
            .zip(makeRemoteFeedLoader(after: last))
            .map { (cachedItems, newItems) in
                (cachedItems + newItems, newItems.last)
            }
            .map(makePage)
            .subscribe(onSome: scheduler)
            .caching(to: localFeedLoader)
    }
    
    private func showComments(for image: FeedImage) {
        let remoteCommentsURL = ImageCommentsEndpoint.get(image.id).url(baseURL: Self.baseURL)
        let commentsVC = CommentUIComposer.commentsComposedWith(
            commentLoaderPublisher: makeRemoteCommentLoader(url: remoteCommentsURL)
        )
        
        feedNavigationController.pushViewController(commentsVC, animated: true)
    }
    
    private func makeRemoteCommentLoader(url: URL) -> () -> AnyPublisher<[ImageComment], any Error> {
        { [httpClient] in
            httpClient
                .getPublisher(for: url)
                .tryMap(ImageCommentMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    private func makeRemoteFeedImageDataLoaderWithLocalFallback(url: URL) -> AnyPublisher<Data, Error> {
        let localFeedImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localFeedImageLoader
            .loadPublisher(from: url)
            .logCacheMisses(url: url, logger: logger)
            .fallback { [httpClient] in
                httpClient
                    .getPublisher(for: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localFeedImageLoader, using: url)
            }
            .subscribe(onSome: scheduler)
            .eraseToAnyPublisher()
    }
}


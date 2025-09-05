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
        window?.rootViewController = feedNavigationController
        
        window?.makeKeyAndVisible()
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        httpClient
            .getPublisher(for: remoteURL)
            .tryMap(FeedMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map { [weak self] items in
                Paginated(items: items, loadMorePublisher: self?.makeRemoteLoadMoreLoader(oldItems: items, last: items.last))
            }
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(oldItems: [FeedImage], last: FeedImage?) -> (() -> AnyPublisher<Paginated<FeedImage>, any Error>)? {
        last.map { lastItem in
            let url = FeedEndpoint.get(after: lastItem.id).url(baseURL: Self.baseURL)
            
            return { [httpClient] in
                httpClient
                    .getPublisher(for: url)
                    .tryMap(FeedMapper.map)
                    .map { newItems in
                        let allItems = oldItems + newItems
                        return Paginated(
                            items: allItems,
                            loadMorePublisher: self.makeRemoteLoadMoreLoader(
                                oldItems: allItems,
                                last: newItems.last
                            )
                        )
                    }
                    .eraseToAnyPublisher()
            }
        }
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
            .fallback { [httpClient] in
                httpClient
                    .getPublisher(for: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localFeedImageLoader, using: url)
            }
    }
}


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


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
       
        
        // Remote
        let client = makeHTTPClient()
        let remoteFeedImageDataLoader = RemoteFeedImageDataLoader(client: client)
        let remoteFeedLoader = RemoteFeedLoader(httpClient: client, url: url)
        
        // Local
        let realmConfig = Realm.Configuration.defaultConfiguration
        let feedStore = RealmFeedStore(realmConfig: realmConfig)
        let localFeedLoader = LocalFeedLoader(store: feedStore, timestamp: Date.init)
        let localFeedImageDataLoader = LocalFeedImageDataLoader(store: feedStore)
        
        
        if CommandLine.arguments.contains("-reset") {
            feedStore.clearCache()
        }
        
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
        
        window?.rootViewController = feedVC
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

private func makeHTTPClient() -> HTTPClient {
    switch UserDefaults.standard.string(forKey: "connectivity") {
    case "offline": return AlwaysFailedHTTPClient()
    default: return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
}

private class AlwaysFailedHTTPClient: HTTPClient {
    
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(.failure(NSError(domain: "offline", code: 0)))
        
        return Task()
    }
}

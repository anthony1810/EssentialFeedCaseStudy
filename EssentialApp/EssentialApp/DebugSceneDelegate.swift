//
//  DebugSceneDelegate.swift
//  EssentialApp
//
//  Created by Anthony on 27/11/24.
//
#if DEBUG
import UIKit
import EssentialFeed

class DebugSceneDelegate: SceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if CommandLine.arguments.contains("-reset") {
            if let url = realmConfig.fileURL {
                try? FileManager.default.removeItem(at: url)
            }
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeHTTPClient() -> any HTTPClient {
        
        if UserDefaults.standard.string(forKey: "connectivity") == "offline"  {
            return AlwaysFailedHTTPClient()
        }
        
        return super.makeHTTPClient()
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

#endif

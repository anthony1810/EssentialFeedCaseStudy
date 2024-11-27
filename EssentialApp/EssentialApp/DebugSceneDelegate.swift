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
        
        if let connectivity = UserDefaults.standard.string(forKey: "connectivity") {
            return DebuggingHTTPClient(connectivity: connectivity)
        }
        
        return super.makeHTTPClient()
    }
}


private class DebuggingHTTPClient: HTTPClient {
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    let connectivity: String
    
    init(connectivity: String) {
        self.connectivity = connectivity
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        switch connectivity {
        case "online":
            completion(makeSuccessfulResponse(for: url))
        default:
            completion(.failure(NSError(domain: "offline", code: 0)))
        }
        
        return Task()
    }
    
    func makeSuccessfulResponse(for url: URL) -> HTTPClient.Result {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = makeData(for: url)
        
        return .success((response, data))
    }
    
    func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!.pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            "items": [
                ["id": UUID().uuidString, "image": "http://image.com"],
                ["id": UUID().uuidString, "image": "http://image.com"]
            ]
        ])
    }
}

#endif

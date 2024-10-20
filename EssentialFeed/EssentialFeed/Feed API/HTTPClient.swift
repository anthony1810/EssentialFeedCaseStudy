//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 5/10/24.
//
import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case failure(Error)
}

public protocol HTTPClient {
    /// the completion handler can be involked in any thread.
    ///  Clients are responsible to dispatch to approriate, thread if need
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 5/10/24.
//
import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(HTTPURLResponse, Data), Error>
    
    /// the completion handler can be involked in any thread.
    ///  Clients are responsible to dispatch to approriate, thread if need
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 5/10/24.
//
import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}

protocol HTTPClient {
    var messages : [(url: URL, completion: (HTTPClientResult) -> Void)] { get }
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

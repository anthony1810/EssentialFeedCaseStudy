//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Anthony on 25/1/25.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, completion: @escaping (Result) -> Void)
}

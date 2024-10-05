//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 5/10/24.
//
import Foundation

protocol HTTPClient {
    var requestedURL: URL? { get }
    func get(url: URL)
}

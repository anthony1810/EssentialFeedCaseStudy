//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Anthony on 2/11/24.
//
import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
    let location: String?
    let description: String?
    let url: URL
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
}

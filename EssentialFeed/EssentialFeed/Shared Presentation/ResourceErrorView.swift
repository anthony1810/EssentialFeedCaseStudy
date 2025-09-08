//
//  FeedErrorView.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation

public struct ResourceErrorViewModel {
    public let message: String?
    
    static var noError: Self {
        ResourceErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ResourceErrorViewModel {
        ResourceErrorViewModel(message: message)
    }
}
public protocol ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel)
}

//
//  FeedErrorViewProtocol.swift
//  EssentialFeed
//
//  Created by Anthony on 6/11/24.
//

public struct LoadResourceErrorViewModel {
    public let message: String?
    
    static var noError: LoadResourceErrorViewModel {
        return LoadResourceErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> LoadResourceErrorViewModel {
        return LoadResourceErrorViewModel(message: message)
    }
}

public protocol LoadResourceErrorViewProtocol {
    func display(_ viewModel: LoadResourceErrorViewModel)
}

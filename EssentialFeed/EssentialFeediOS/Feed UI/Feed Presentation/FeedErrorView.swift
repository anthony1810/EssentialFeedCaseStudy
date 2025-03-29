//
//  FeedErrorView.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation
import EssentialFeed

struct FeedErrorViewModel {
    let message: String?
    
    static var none: Self {
        .init(message: nil)
    }
}
protocol FeedErrorView {
    func display(viewModel: FeedErrorViewModel)
}

//
//  FeedView.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation
import EssentialFeed

struct FeedViewModel {
    var feeds: [FeedImage]
}
protocol FeedView {
    func display(viewModel: FeedViewModel)
}

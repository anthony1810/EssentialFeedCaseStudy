//
//  FeedLoadingView.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation
import EssentialFeed

struct LoadingViewModel {
    var isLoading: Bool
}
protocol FeedLoadingView {
    func display(viewModel: LoadingViewModel)
}

//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 6/11/24.
//
import Foundation

public final class FeedImagePresenter {
    public static func map(_ model: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            location: model.location,
            description: model.description
        )
    }
}

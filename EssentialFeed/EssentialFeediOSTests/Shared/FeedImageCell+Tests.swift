//
//  FeedImageCell+Tests.swift
//  EssentialFeed
//
//  Created by Anthony on 22/2/25.
//
import EssentialFeediOS

public extension FeedImageCell {
    var isShowingLocation: Bool {
        locationContainer.isHidden == false
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var isShowingLoadingIndicator: Bool {
        imageContainer.isShimmering
    }
    
    var isShowingRetryButton: Bool {
        retryButton.isHidden == false
    }
    
    func simulateButtonTapped() {
        retryButton.simulateButtonTapped()
    }
    
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
}

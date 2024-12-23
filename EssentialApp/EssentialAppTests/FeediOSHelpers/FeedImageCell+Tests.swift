//
//  FeedImageCell+Tests.swift
//  EssentialFeed
//
//  Created by Anthony on 28/10/24.
//
import Foundation
import EssentialFeediOS
import UIKit

extension FeedImageCell {
    var isShowingLocation: Bool {
        locationLabel.isHidden == false
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    func isShowingImageLoadingIndicator() -> Bool {
        imageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        let imageData = feedImageView.image?.pngData()
        return imageData
    }
    
    var showingRetryButton: Bool {
        retryButton.isHidden == false
    }
    
    func triggerRetryAction() {
        retryButton.simulateTap()
    }
}

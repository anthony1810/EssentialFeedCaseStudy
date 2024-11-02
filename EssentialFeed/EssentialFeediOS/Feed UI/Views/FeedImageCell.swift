//
//  FeedImageCell.swift
//  EssentialFeed
//
//  Created by Anthony on 29/10/24.
//
import Foundation
import UIKit

public final class FeedImageCell: UITableViewCell {
    @IBOutlet public var locationLabel: UILabel!
    @IBOutlet public var descriptionLabel: UILabel!
    
    @IBOutlet public var imageContainer: UIView!
    @IBOutlet public var feedImageView: UIImageView!
    @IBOutlet public var retryButton: UIButton!
    
    public var url: URL!
    
    var onRetryButtonTapped: (() -> Void)?
    
    @objc
    @IBAction func retryButtonTapped() {
        onRetryButtonTapped?()
    }
}

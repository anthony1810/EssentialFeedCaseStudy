//
//  FeedImageCell.swift
//  EssentialFeed
//
//  Created by Anthony on 22/2/25.
//
import UIKit

public class FeedImageCell: UITableViewCell {
    public var locationContainer = UIView()
    public var locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let imageContainer = UIView()
    public let feedImageView = UIImageView()
    
    public var onRetry: (() -> Void)?
    
    public private(set) lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc public func retryButtonTapped() {
        onRetry?()
    }
    
}


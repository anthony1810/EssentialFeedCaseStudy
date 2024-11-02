//
//  FeedImageCell.swift
//  EssentialFeed
//
//  Created by Anthony on 29/10/24.
//
import Foundation
import UIKit

public final class FeedImageCell: UITableViewCell {
    public let locationLabel: UILabel = .init()
    public let descriptionLabel: UILabel = .init()
    public var url: URL!
    public let imageContainer: UIView = .init()
    public var feedImageView: UIImageView = .init()
    public lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetryButtonTapped: (() -> Void)?
    
    @objc
    func retryButtonTapped() {
        onRetryButtonTapped?()
    }
}

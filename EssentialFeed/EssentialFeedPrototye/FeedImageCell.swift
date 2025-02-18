//
//  FeedImageCell.swift
//  EssentialFeed
//
//  Created by Anthony on 13/2/25.
//

import UIKit

final class FeedImageCell: UITableViewCell {
    @IBOutlet weak var locationContainer: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(with viewModel: FeedImageViewModel) {
        locationLabel.text = viewModel.location
        locationContainer.isHidden = viewModel.location == nil
        
        descriptionLabel.text = viewModel.description
        descriptionLabel.isHidden = viewModel.description == nil
        
        imgView.image = UIImage(named: viewModel.imageName)
        
    }
}



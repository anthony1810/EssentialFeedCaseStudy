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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgView.alpha = 0
    }
    
    func configure(with viewModel: FeedImageViewModel) {
        locationLabel.text = viewModel.location
        locationContainer.isHidden = viewModel.location == nil
        
        descriptionLabel.text = viewModel.description
        descriptionLabel.isHidden = viewModel.description == nil
        
        fadeIn(UIImage(named: viewModel.imageName)!)
    }
    
    func fadeIn(_ image: UIImage) {
        imgView.image = image
        
        UIView.animate(withDuration: 0.3, delay: 0.3) {
            self.imgView.alpha = 1
        }
    }
}



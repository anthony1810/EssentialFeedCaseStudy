//
//  ImageStub.swift
//  EssentialFeed
//
//  Created by Anthony on 26/7/25.
//
import UIKit
import EssentialFeediOS
@testable import EssentialFeed

class ImageStub: FeedImageCellControllerDelegate {
    weak var controller: FeedImageCellController?
    private var image: UIImage?
    var viewModel: FeedImageViewModel
    
    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel(
            location: location,
            description: description
        )
        self.image = image
    }
    
    func didRequestImage() {
        controller?.display(viewModel: .init(isLoading: false))
        
        if let image {
            controller?.display(image)
        } else {
            controller?.display(ResourceErrorViewModel(message: "any"))
        }
    }
    
    func didCancelImageRequest() {}
}

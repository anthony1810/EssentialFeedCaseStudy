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
    private let viewModel: FeedImageViewModel<UIImage>
    
    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel(
            location: location,
            description: description,
            image: image,
            isLoading: false,
            shouldRetry: image == nil
        )
    }
    
    func didRequestImage() {
        controller?.display(viewModel: viewModel)
    }
    
    func didCancelImageRequest() {}
}

//
//  CommensViewAdapter.swift
//  EssentialApp
//
//  Created by Anthony on 20/8/25.
//
import EssentialFeed
import EssentialFeediOS
import UIKit
import Combine

final class CommentsViewAdapter: ResourceView {
    typealias ResourceViewModel = ImageCommentsViewModel
    private weak var controller: ListViewController?
    
    init(
        controller: ListViewController? = nil
    ) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { model in
            CellController(id: model, ds: ImageCommentCellController(viewModel: model))
        })
    }
}

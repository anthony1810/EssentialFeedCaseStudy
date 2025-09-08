//
//  ImageCommentCellController.swift
//  EssentialFeed
//
//  Created by Anthony on 10/8/25.
//
import UIKit
import EssentialFeed

public final class ImageCommentCellController: NSObject, UITableViewDataSource {
    private let viewModel: ImageCommentViewModel
    private var cell: ImageCommentCell?
    
    public init (viewModel: ImageCommentViewModel) {
        self.viewModel = viewModel
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell? = tableView.dequeueReusableCell()
        self.cell = cell
        
        cell?.authorLabel.text = viewModel.username
        cell?.dateLabel.text = viewModel.date
        cell?.commentLabel.text = viewModel.message
        
        return cell!
    }
}

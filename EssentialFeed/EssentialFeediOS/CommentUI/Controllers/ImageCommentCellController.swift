//
//  ImageCommentCellController.swift
//  EssentialFeed
//
//  Created by Anthony on 18/12/24.
//
import UIKit
import EssentialFeed

public final class ImageCommentCellController: CellController {
    let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.author.text = model.username
        cell.date.text = model.date
        cell.message.text = model.message
        
        return cell
    }
    
    public func prefetch() {
        
    }
    
    public func cancelLoading() {
        
    }
}

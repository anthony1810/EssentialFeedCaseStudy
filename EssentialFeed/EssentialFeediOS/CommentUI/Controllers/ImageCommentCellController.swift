//
//  ImageCommentCellController.swift
//  EssentialFeed
//
//  Created by Anthony on 18/12/24.
//
import UIKit
import EssentialFeed

public final class ImageCommentCellController: NSObject, UITableViewDataSource {
    let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.author.text = model.username
        cell.date.text = model.date
        cell.message.text = model.message
        
        return cell
    }
}

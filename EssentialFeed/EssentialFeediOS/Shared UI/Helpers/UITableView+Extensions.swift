//
//  UITableView+Extensions.swift
//  EssentialFeed
//
//  Created by Anthony on 23/3/25.
//
import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T? {
        let identifier = String(describing: T.self)
        
        return dequeueReusableCell(withIdentifier: identifier) as? T
    }
    
    func sizeTableHeaderToFit() {
        guard let header = tableHeaderView else { return }
        
        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        let needsFrameUpdate = header.frame.size != size
        tableHeaderView?.backgroundColor = .red
        if needsFrameUpdate {
            header.frame.size = size
            tableHeaderView = header
            
        }
    }
}

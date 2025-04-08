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
}

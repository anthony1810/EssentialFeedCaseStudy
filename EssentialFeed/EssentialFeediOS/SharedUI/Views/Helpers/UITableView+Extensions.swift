//
//  UITableView+Extensions.swift
//  EssentialFeed
//
//  Created by Anthony on 2/11/24.
//
import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        self.dequeueReusableCell(withIdentifier: String(describing: T.self)) as! T
    }
}

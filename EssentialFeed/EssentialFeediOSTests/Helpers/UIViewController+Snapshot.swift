//
//  UIViewController+Snapshot.swift
//  EssentialFeed
//
//  Created by Anthony on 26/7/25.
//

import Foundation
import UIKit

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

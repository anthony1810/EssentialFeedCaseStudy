//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 20/2/25.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    var loader: FeedLoader?
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc
    func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [unowned self] _ in
            self.refreshControl?.endRefreshing()
        }
    }
}

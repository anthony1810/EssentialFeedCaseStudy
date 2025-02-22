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
    var items: [FeedImage] = []
    
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
        loader?.load { [unowned self] result in
            if case let .success(items) = result {
                self.items = items
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feed = items[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = feed.location == nil
        cell.descriptionLabel.text = feed.description
        cell.locationLabel.text = feed.location
        
        return cell
    }
}

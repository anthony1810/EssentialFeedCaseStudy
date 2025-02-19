//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 13/2/25.
//

import UIKit

final class FeedViewController: UITableViewController {
    var feed: [FeedImageViewModel] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }
    
    @IBAction func refresh() {
        self.refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [unowned self] in
            if self.feed.isEmpty {
                self.feed = FeedImageViewModel.prototypeFeed
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedViewCell", for: indexPath) as! FeedImageCell
        cell.configure(with: feed[indexPath.row])
        return cell
    }
}

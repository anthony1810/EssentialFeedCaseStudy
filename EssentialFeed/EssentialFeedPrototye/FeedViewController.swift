//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 13/2/25.
//

import UIKit

final class FeedViewController: UITableViewController {
    let feed: [FeedImageViewModel] = FeedImageViewModel.prototypeFeed
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedViewCell", for: indexPath) as! FeedImageCell
        cell.configure(with: feed[indexPath.row])
        return cell
    }
}

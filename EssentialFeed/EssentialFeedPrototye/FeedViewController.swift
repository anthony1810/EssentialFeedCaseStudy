//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 13/2/25.
//

import UIKit

final class FeedViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedViewCell", for: indexPath)
        
        return cell
    }
}

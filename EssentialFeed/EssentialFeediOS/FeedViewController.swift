//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 26/10/24.
//
import Foundation
import UIKit
import EssentialFeed

public final class FeedImageCell: UITableViewCell {
    public let locationLabel: UILabel = .init()
    public let descrtipionLabel: UILabel = .init()
    public var url: URL?
}

public final class FeedViewController: UITableViewController {
    private var loader: FeedLoader
    private var feeds: [FeedImage] = []
    
    private var onViewFirstAppear: (() -> Void)?
    
    public init(loader: FeedLoader) {
        self.loader = loader
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(loadFeeds), for: .valueChanged)
        
        onViewFirstAppear = { [weak self] in
            self?.loadFeeds()
            self?.onViewFirstAppear = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewFirstAppear?()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feeds.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feed = feeds[indexPath.row]
        let cell = FeedImageCell()
        cell.locationLabel.text = feed.location
        cell.descrtipionLabel.text = feed.description
        cell.url = feed.imageURL
        
        return cell
    }
    
    @objc
    public func loadFeeds() {
        self.refreshControl?.beginRefreshing()
        loader.load(completion: { [weak self] result in
            self?.feeds = (try? result.get()) ?? []
            self?.refreshControl?.endRefreshing()
            self?.tableView.reloadData()
        })
    }
}

//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 26/10/24.
//
import Foundation
import UIKit
import EssentialFeed

public protocol ImageLoadingDataTaskProtocol {
    func cancel()
}

public protocol FeedImageLoaderProtocol {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageLoadingDataTaskProtocol
}

public final class FeedImageCell: UITableViewCell {
    public let locationLabel: UILabel = .init()
    public let descrtipionLabel: UILabel = .init()
    public var url: URL!
    public let imageContainer: UIView = .init()
    public var feedImageView: UIImageView = .init()
    public lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetryButtonTapped: (() -> Void)?
    
    @objc
    func retryButtonTapped() {
        onRetryButtonTapped?()
    }
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var loader: FeedLoader
    private var imageLoader: FeedImageLoaderProtocol
    
    private var feeds: [FeedImage] = []
    private var loadingImageTasks: [IndexPath: ImageLoadingDataTaskProtocol] = [:]
    
    private var onViewFirstAppear: (() -> Void)?
    
    public init(loader: FeedLoader, imageLoader: FeedImageLoaderProtocol) {
        self.loader = loader
        self.imageLoader = imageLoader
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(loadFeeds), for: .valueChanged)
        tableView.prefetchDataSource = self
        
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
        cell.imageContainer.isShimmering = true
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true
        
        let loadImage = { [weak cell, weak self] in
            guard let self, let cell else { return }
            
            self.loadingImageTasks[indexPath] = self.imageLoader.loadImageData(from: cell.url, completion: { [cell] result in
              
                let imageData = try? result.get()
                let convertedImage = imageData.map(UIImage.init) ?? nil
                cell.feedImageView.image = convertedImage
                
                cell.retryButton.isHidden = convertedImage != nil
                
                cell.imageContainer.isShimmering = false
            })
        }
        
        cell.onRetryButtonTapped = loadImage
        loadImage()
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      
        loadingImageTasks[indexPath]?.cancel()
        loadingImageTasks[indexPath] = nil
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let feed = feeds[indexPath.row]
            _ = self.imageLoader.loadImageData(from: feed.imageURL, completion: { _ in })
        }
    }
    
    @objc
    public func loadFeeds() {
        self.refreshControl?.beginRefreshing()
        loader.load(completion: { [weak self] result in
            if case let .success(feeds) = result {
                self?.feeds = feeds
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        })
    }
}

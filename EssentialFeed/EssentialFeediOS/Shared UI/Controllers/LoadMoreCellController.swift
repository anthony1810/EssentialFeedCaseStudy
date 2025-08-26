//
//  LoadMoreCellController.swift
//  EssentialFeed
//
//  Created by Anthony on 26/8/25.
//

import UIKit
import EssentialFeed

public final class LoadMoreCell: UITableViewCell {
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .label
        contentView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            spinner.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0)
        ])
        
        return spinner
    }()
    
    var isLoading: Bool {
        get { spinner.isAnimating }
        set {
            if newValue {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
    }
}

public final class LoadMoreCellController: NSObject, UITableViewDataSource {
    private let cell: LoadMoreCell = .init()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell
    }
}

extension LoadMoreCellController: ResourceLoadingView {
    public func display(viewModel: EssentialFeed.ResourceLoadingViewModel) {
        cell.isLoading = viewModel.isLoading
    }
}

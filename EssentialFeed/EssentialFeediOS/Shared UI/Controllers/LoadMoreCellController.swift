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
    
    public var isLoading: Bool {
        get { spinner.isAnimating }
        set {
            if newValue {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
    }
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .tertiaryLabel
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        return label
    }()
    
    public var message: String? {
        get { messageLabel.text }
        set { messageLabel.text = newValue }
    }
}

public final class LoadMoreCellController: NSObject, UITableViewDataSource, UITableViewDelegate {
    private let cell = LoadMoreCell()
    private let willDisplayCallback: () -> Void
    private var offsetObserver: NSKeyValueObservation?
    
    public init(willDisplayCallback: @escaping () -> Void) {
        self.willDisplayCallback = willDisplayCallback
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell.selectionStyle = .none
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print()
//        triggerLoadMoreCallback()
//        offsetObserver = tableView.observe(\.contentOffset, options: .new) { [weak self] (tableView, _) in
//            guard tableView.isDragging else { return }
//            
//            self?.triggerLoadMoreCallback()
//        }
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        offsetObserver = nil
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        triggerLoadMoreCallback()
    }
}

extension LoadMoreCellController: ResourceLoadingView {
    public func display(viewModel: EssentialFeed.ResourceLoadingViewModel) {
        cell.isLoading = viewModel.isLoading
    }
}

extension LoadMoreCellController: ResourceErrorView {
    public func display(_ viewModel: EssentialFeed.ResourceErrorViewModel) {
        cell.message = viewModel.message
    }
}

private extension LoadMoreCellController {
    func triggerLoadMoreCallback() {
        guard !self.cell.isLoading else { return }
        
        willDisplayCallback()
    }
}

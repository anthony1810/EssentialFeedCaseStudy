//
//  CellController.swift
//  EssentialFeed
//
//  Created by Anthony on 18/12/24.
//
import Foundation
import UIKit
import EssentialFeed

public struct CellController {
    let datasource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let prefetching: UITableViewDataSourcePrefetching?
    
    public init(datasource: UITableViewDataSource, delegate: UITableViewDelegate?, prefetching: UITableViewDataSourcePrefetching?) {
        self.datasource = datasource
        self.delegate = delegate
        self.prefetching = prefetching
    }
    
    public init(datasource: UITableViewDataSource) {
        self.datasource = datasource
        self.delegate = nil
        self.prefetching = nil
    }
}

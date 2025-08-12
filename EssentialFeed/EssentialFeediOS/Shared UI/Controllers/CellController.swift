//
//  CellController.swift
//  EssentialFeed
//
//  Created by Anthony on 12/8/25.
//
import UIKit

public struct CellController {
    let ds: UITableViewDataSource
    let dl: UITableViewDelegate?
    let dsPrefetching: UITableViewDataSourcePrefetching?
    
    public init(ds: UITableViewDataSource, dl: UITableViewDelegate?, dsPrefetching: UITableViewDataSourcePrefetching?) {
        self.ds = ds
        self.dl = dl
        self.dsPrefetching = dsPrefetching
    }
    
    public init(ds: UITableViewDataSource) {
        self.ds = ds
        self.dl = nil
        self.dsPrefetching = nil
    }
}

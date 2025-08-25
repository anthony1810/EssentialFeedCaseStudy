//
//  CellController.swift
//  EssentialFeed
//
//  Created by Anthony on 12/8/25.
//
import UIKit

public struct CellController {
    let id: AnyHashable
    let ds: UITableViewDataSource
    let dl: UITableViewDelegate?
    let dsPrefetching: UITableViewDataSourcePrefetching?
    
    public init(id: AnyHashable, ds: UITableViewDataSource, dl: UITableViewDelegate?, dsPrefetching: UITableViewDataSourcePrefetching?) {
        self.id = id
        self.ds = ds
        self.dl = dl
        self.dsPrefetching = dsPrefetching
    }
    
    public init(id: AnyHashable, ds: UITableViewDataSource) {
        self.id = id
        self.ds = ds
        self.dl = nil
        self.dsPrefetching = nil
    }
}

extension CellController: Equatable {
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}

extension CellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

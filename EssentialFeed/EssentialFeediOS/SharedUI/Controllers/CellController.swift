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
    let id: AnyHashable
    let datasource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let prefetching: UITableViewDataSourcePrefetching?
    
    public init(id: AnyHashable, datasource: UITableViewDataSource, delegate: UITableViewDelegate?, prefetching: UITableViewDataSourcePrefetching?) {
        self.id = id
        self.datasource = datasource
        self.delegate = delegate
        self.prefetching = prefetching
    }
    
    public init(id: AnyHashable, datasource: UITableViewDataSource) {
        self.id = id
        self.datasource = datasource
        self.delegate = nil
        self.prefetching = nil
    }
}

extension CellController: Equatable {
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}
extension CellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

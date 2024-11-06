//
//  LocalizedStringHelpers.swift
//  EssentialFeed
//
//  Created by Anthony on 3/11/24.
//
import Foundation
import EssentialFeed

func localizedString(for key: String) -> String {
    NSLocalizedString(key, tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), value: "", comment: "")
}

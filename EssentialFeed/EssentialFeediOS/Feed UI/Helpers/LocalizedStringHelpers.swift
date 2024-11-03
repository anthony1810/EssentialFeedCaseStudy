//
//  LocalizedStringHelpers.swift
//  EssentialFeed
//
//  Created by Anthony on 3/11/24.
//
import Foundation

func localizedString(for key: String) -> String {
    NSLocalizedString(key, tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), value: "", comment: "")
}

//
//  SnapshotConfiguration.swift
//  EssentialFeed
//
//  Created by Anthony on 26/7/25.
//
import UIKit

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection
    
    static func iphone8(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
        SnapshotConfiguration(
            size: CGSize(width: 375, height: 667),
            safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
            layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
            traitCollection: UITraitCollection(mutations: { mutableTraits in
                mutableTraits.forceTouchCapability = .available
                mutableTraits.layoutDirection = .leftToRight
                mutableTraits.userInterfaceIdiom = .phone
                mutableTraits.horizontalSizeClass = .compact
                mutableTraits.verticalSizeClass = .regular
                mutableTraits.displayScale = 2
                mutableTraits.displayGamut = .P3
                mutableTraits.userInterfaceStyle = style
            })
        )
    }
}

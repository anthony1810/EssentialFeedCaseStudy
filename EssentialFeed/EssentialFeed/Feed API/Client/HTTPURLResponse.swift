//
//  HTTPURLResponse.swift
//  EssentialFeed
//
//  Created by Anthony on 16/11/24.
//

import Foundation

extension HTTPURLResponse {
    
    private static var OK_200: Int { 200 }
    
    var isOK: Bool {
        statusCode == HTTPURLResponse.OK_200
    }
}

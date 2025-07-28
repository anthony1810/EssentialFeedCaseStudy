//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Anthony on 6/4/25.
//

import Foundation

extension HTTPURLResponse {
    public static var OK_200: Int { 200 }
    
    var isOK: Bool {
        statusCode == HTTPURLResponse.OK_200
    }
}

//
//  AccessToken.swift
//  iosTest
//
//  Created by Alex Iartsev on 09/12/2017.
//  Copyright © 2017 Alex Iartsev. All rights reserved.
//

import Foundation

struct AccessToken: Codable {
    let token: String
    let deviceId: String
    let expiresIn: Int
    let createdAt: Date  = Date()
    
    enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case deviceId = "device_id"
        case expiresIn = "expires_in"
    }
}

extension AccessToken {
    var expired: Bool {
        get {
            let timeDifference = Calendar.current.dateComponents([.second], from: createdAt, to: Date())
            
            guard let seconds = timeDifference.second else {
                return true
            }
            return seconds > expiresIn
        }
    }
}

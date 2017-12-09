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
    
    enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case deviceId = "device_id"
        case expiresIn = "expires_in"
    }
}

extension AccessToken {
    //TODO: Add check later to see if AccessToken expired
    
    var expired: Bool {
        get {
            return true
        }
    }
}

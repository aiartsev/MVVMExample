//
//  RedditEntry.swift
//  iosTest
//
//  Created by Alex Iartsev on 08/12/2017.
//  Copyright © 2017 Alex Iartsev. All rights reserved.
//

import Foundation

struct RedditEntry: Codable {
    let title: String
    let author: String
    let created: Double
    let thumbnail: String
    let comments: Int
    
    enum CodingKeys: String, CodingKey {
        case author
        case thumbnail
        case created
        case title
        case comments = "num_comments"
    }
}

struct EntryWrapper: Codable {
    let data: RedditEntry
}

struct TopListing: Codable {
    let modHash: String
    let entries: [EntryWrapper]
    let after: String?
    let before: String?
    
    enum CodingKeys: String, CodingKey {
        case modHash = "modhash"
        case entries = "children"
        case after
        case before
    }
}

struct ListingWrapper: Codable {
    let data: TopListing
}

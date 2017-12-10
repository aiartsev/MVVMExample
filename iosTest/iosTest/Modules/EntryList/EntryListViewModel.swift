//
//  EntryListViewModel.swift
//  iosTest
//
//  Created by Alex Iartsev on 09/12/2017.
//  Copyright © 2017 Alex Iartsev. All rights reserved.
//

import Foundation

class EntryListViewModel {
    
    var reloadTableView: (()->())?
    var showAlert: (()->())?
    var updateLoadingStatus: (()->())?
    
    let redditApi: APIService
    let deviceId: String
    
    private var entryList: [RedditEntry] = [RedditEntry]()
    
    private var cellViewModels: [EntryListCellViewModel] = [EntryListCellViewModel]() {
        didSet {
            self.reloadTableView?()
        }
    }
    
    var loading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlert?()
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    init(withDeviceId id: String, withAPIService apiService: APIService = RedditAPI()) {
        self.redditApi = apiService
        self.deviceId = id
    }
    
    func loadData() {
        self.loading = true
        
        redditApi.authorize(deviceId: self.deviceId) { [weak self] (success, error) in
            if let error = error {
                self?.loading = false
                self?.alertMessage = error.localizedDescription
            } else if !success {
                self?.loading = false
                self?.alertMessage = "Unknown Authentication Error."
            } else {
                self?.redditApi.getListings() { [weak self] (success, topListing, error) in
                    self?.loading = false
                    if let error = error {
                        self?.alertMessage = error.localizedDescription
                    } else if !success {
                        self?.alertMessage = "Unknown Error."
                    } else if let listing = topListing {
                        self?.prepareListing(listing)
                    }
                    
                    self?.alertMessage = "Error Getting Top Listing"
                }
            }
        }
    }
    
    private func prepareListing(_  listing: TopListing) {
        for entry in listing.entries {
            print(entry.data)
        }
    }
}

class EntryListCellViewModel {
    
    init(withEntry: RedditEntry) {
        
    }
}

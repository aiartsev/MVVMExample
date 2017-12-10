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
    
    let redditApi: RedditAPI
 
    var lastEntryId: String?
    
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
    
    init(withAPIService apiService: RedditAPI) {
        self.redditApi = apiService
    }
    
    func loadData(displayLoading: Bool = false) {
        if displayLoading {
            self.loading = true
        }
        redditApi.getListings(afterEntry: lastEntryId) { [weak self] (success, topListing, error) in
            self?.loading = false
            if let error = error {
                self?.alertMessage = error.localizedDescription
            } else if !success {
                self?.alertMessage = "Unknown Error."
            } else if let listing = topListing {
                self?.prepareListing(listing)
            } else {
                self?.alertMessage = "Error Getting Top Listing."
            }
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> EntryListCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    private func prepareListing(_  listing: TopListing) {
        for entryWrapper in listing.entries {
            self.entryList.append(entryWrapper.data)
            self.cellViewModels.append(EntryListCellViewModel(withEntry: entryWrapper.data))
        }
        
        self.lastEntryId = listing.after
        self.reloadTableView?()
    }
}

class EntryListCellViewModel {
    
    let titleText: String
    let authorText: String
    let thumbnailURL: String
    let validThumbnail: Bool
    let imageURL: String?
    let dateText: String
    let commentsText: String
    
    init(withEntry entry: RedditEntry) {
        self.titleText = entry.title
        self.authorText = entry.author
        self.thumbnailURL = entry.thumbnail
        self.validThumbnail  = false
        self.commentsText = "\(entry.comments) comments"
        self.imageURL = entry.image
        
        let date = Date(timeIntervalSince1970: entry.created)
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        
        let formatString = NSLocalizedString("%@ ago", comment: "")
        let timeString = formatter.string(from: date, to: Date())
        self.dateText = String(format: formatString, timeString!)
    }
}

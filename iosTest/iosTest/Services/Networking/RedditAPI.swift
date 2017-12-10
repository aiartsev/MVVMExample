//
//  RedditAPI.swift
//  iosTest
//
//  Created by Alex Iartsev on 09/12/2017.
//  Copyright © 2017 Alex Iartsev. All rights reserved.
//

import Foundation

class RedditAPI {
    let GRANT_TYPE = "https://oauth.reddit.com/grants/installed_client"
    let USER_NAME = "-DBHvhMD--SHKg:"
    let POST = "POST"
    let CONTENT_TYPE = "Content-Type"
    let URL_ENCODED = "application/x-www-form-urlencoded"
    let AUTHORIZATION = "Authorization"
    let HOST = "https://www.reddit.com/"
    let AUTH_URI = "api/v1/access_token"
    
    let uuid: String
    
    var accessToken: AccessToken?
    
    init (withDeviceId id: String) {
        self.uuid = id
    }
    
    func authorize(deviceId uuid: String, withCompletion completion: @escaping (Bool, Error?) -> ()) {
        let session = URLSession(configuration: .ephemeral)
        let url = URL(string: "\(HOST)\(AUTH_URI)?grant_type=\(GRANT_TYPE)&device_id=\(uuid)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = POST

        let credentials = "Basic \(Data(USER_NAME.utf8).base64EncodedString())"
        request.setValue(credentials, forHTTPHeaderField: AUTHORIZATION)
        request.setValue(URL_ENCODED, forHTTPHeaderField: CONTENT_TYPE)
        
        let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let data = data else {
                completion(false, error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                self.accessToken = try decoder.decode(AccessToken.self, from: data)
            } catch let error {
                completion(false, error)
                print(error.localizedDescription)
                return
            }
            
            print(self.accessToken ?? "ERROR")
            completion(true, error)
        })
        
        task.resume()
    }
    
    func getListings(afterEntry: String?, withCompletion completion: @escaping (Bool, TopListing?, Error?) -> ()) {
        if let accessToken = self.accessToken {
            if (!accessToken.expired) {
                let session = URLSession(configuration: .ephemeral)
                
                var urlString = "https://oauth.reddit.com/top"
                
                if let entryId = afterEntry {
                   urlString = urlString.appending("?after=\(entryId)")
                }
                
                let url = URL(string: urlString)!
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                request.setValue("Bearer \(accessToken.token)", forHTTPHeaderField: AUTHORIZATION)
                request.setValue(URL_ENCODED, forHTTPHeaderField: CONTENT_TYPE)
                
                let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?)  -> Void in
                    guard let data = data else {
                        completion(false, nil, error)
                        return
                    }
                    
                    do  {
                        let decoder = JSONDecoder()
                        let listingWrapper = try decoder.decode(ListingWrapper.self, from: data)
                        completion(true, listingWrapper.data, error)
                        return
                    } catch let error {
                        completion(false, nil, error)
                        print(error.localizedDescription)
                        return
                    }
                })
                
                task.resume()
                return
            }
        }
        
        self.authorize(deviceId: uuid) { [weak self] (success, error) in
            if let error = error {
                completion(false, nil, error)
                return
            }
            
            self?.getListings(afterEntry: afterEntry, withCompletion: completion)
        }
    }
}

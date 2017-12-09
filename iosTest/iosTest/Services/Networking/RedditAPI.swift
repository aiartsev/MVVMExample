//
//  RedditAPI.swift
//  iosTest
//
//  Created by Alex Iartsev on 09/12/2017.
//  Copyright © 2017 Alex Iartsev. All rights reserved.
//

import Foundation

protocol APIService {
    func authorize(deviceId uuid: String, withCompletion completion: @escaping ( _ success: Bool, _ error: Error? )->())
}

class RedditAPI: APIService {
    let GRANT_TYPE = "https://oauth.reddit.com/grants/installed_client"
    let USER_NAME = "-DBHvhMD--SHKg:"
    let POST = "POST"
    let CONTENT_TYPE = "Content-Type"
    let URL_ENCODED = "application/x-www-form-urlencoded"
    let AUTHORIZATION = "Authorization"
    let HOST = "https://www.reddit.com/"
    let AUTH_URI = "api/v1/access_token"
    
    var token: AccessToken?
    
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
                self.token = try decoder.decode(AccessToken.self, from: data)
            } catch let error {
                print(error)
            }
            
            print(self.token ?? "ERROR")
        })
        
        task.resume()
    }
    
    func getListings(withCompletion completion: @escaping (Error?) -> ()) {
        
    }
}

//
//  NetworkingManager.swift
//  rüm
//
//  Created by Andrew Fang on 4/20/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class NetworkingManager {
    
    // Use this class as a singleton
    static let sharedInstance = NetworkingManager()
    
    func registerUser(userid:String, deviceToken:String) {
        let registerEndpoint = "http://rumapi.herokuapp.com/register"
        let jsonArray = ["userId":userid, "deviceId":deviceToken, "accessToken":FBSDKAccessToken.currentAccessToken().tokenString]
        if let json = try? NSJSONSerialization.dataWithJSONObject(jsonArray, options: NSJSONWritingOptions(rawValue: 0)) {
            if let jsonString = NSString(data: json, encoding: NSUTF8StringEncoding) {
                self.sendPostRequest(registerEndpoint, body: String(jsonString))
            }
        }
    }
    
    func sendPostRequest(endpoint:String, body:String) {
        let request = NSMutableURLRequest(URL: NSURL(string: endpoint)!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let postString = body
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            // check for fundamental networking error
            guard error == nil && data != nil else {
                print("error=\(error)")
                return
            }
            
            // check for http errors
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
}
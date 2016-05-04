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
    
    struct Constants {
        static let USER_JOINED_GROUP = "USER_JOINED_GROUP"
        static let USER_CREATED_GROUP = "USER_CREATED_GROUP"
        static let CHECK_USER_EXISTS = "CHECK_USER_EXISTS"
    }
    
    func registerUser(userid:String, deviceToken:String, firstName:String, lastName:String, imageUrl:String) {
        let registerEndpoint = "http://rumapi.herokuapp.com/register"
        let jsonArray = ["userId":userid, "deviceId":deviceToken, "accessToken":FBSDKAccessToken.currentAccessToken().tokenString, "firstName":firstName, "lastName":lastName, "photo":imageUrl]
        self.sendPostRequest(registerEndpoint, body: jsonArray, handler: nil)
    }
    
    func checkUser(userid:String) {
        self.sendRequest("http://rumapi.herokuapp.com/user/\(userid)", body: [:], method: "GET", useJSON: false, handler: { data, response, error in
            var userInfo = [String: AnyObject]()
            if let response = response as? NSHTTPURLResponse {
                userInfo["response"] = response
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                userInfo["data"] = json
            } catch {
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.CHECK_USER_EXISTS, object: nil, userInfo: userInfo)
        })
    }
    
    func createGroup(userid:String, groupname:String) {
        let createEndpoint = "http://rumapi.herokuapp.com/group"
        let jsonArray = ["name":groupname, "userId":userid]
        self.sendPostRequest(createEndpoint, body: jsonArray, handler: { data, response, error in
            print(response)
            if let response = response as? NSHTTPURLResponse {
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.USER_CREATED_GROUP, object: nil, userInfo: ["response":response])
            }
            
        })
    }
    
    func joinUserToGroup(userid:String, groupId:String) {
        // TODO: Send post request
        self.sendRequest("http://rumapi.herokuapp.com/group/\(groupId)", body: ["userId":userid], method: "PUT", useJSON: true, handler: { data, response, error in
            if let response = response as? NSHTTPURLResponse {
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.USER_JOINED_GROUP, object: nil, userInfo: ["response":response])
            }
        })
    }
    
    func sendPostRequest(endpoint:String, body:[String: AnyObject], handler:((NSData?, NSURLResponse?, NSError?) -> Void)?) {
        self.sendRequest(endpoint, body: body, method: "POST", useJSON: true, handler: handler)
    }
    
    func getGroupInfo(groupId:String) {
        self.sendRequest("http://rumapi.herokuapp.com/group/\(groupId)", body: [:], method: "GET", useJSON: true, handler: nil)
    }
    
    func sendRequest(endpoint:String, body:[String: AnyObject], method:String, useJSON:Bool, handler:((NSData?, NSURLResponse?, NSError?) -> Void)?) {
        let request = NSMutableURLRequest(URL: NSURL(string: endpoint)!)
        request.HTTPMethod = method
        if (useJSON) {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
            guard let json = try? NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(rawValue: 0)) else {
                return
            }
            
            guard let jsonBody = NSString(data: json, encoding: NSUTF8StringEncoding) else {
                return
            }
            
            let postString = String(jsonBody)
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        
        
        var handlerBlock:(NSData?, NSURLResponse?, NSError?) -> Void
        if handler != nil {
            handlerBlock = handler!
        } else {
            handlerBlock = { data, response, error in
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
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: handlerBlock)
        task.resume()
    }
}
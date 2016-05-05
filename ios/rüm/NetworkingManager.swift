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
        static let LAST_TASK = "LAST_TASK"
    }
    
    func registerUser(userid:String, deviceToken:String?, firstName:String, lastName:String, imageUrl:String) {
        let registerEndpoint = "http://rumapi.herokuapp.com/register"
        var bodyDict = ["userId":userid, "accessToken":FBSDKAccessToken.currentAccessToken().tokenString, "firstName":firstName, "lastName":lastName, "photo":imageUrl]
        
        if let deviceId = deviceToken {
            bodyDict["deviceId"] = deviceId
        }
        
        self.sendPostRequest(registerEndpoint, body: bodyDict, handler: nil)
    }
    
    func checkUser(userid:String) {
        self.sendGetRequest("http://rumapi.herokuapp.com/user/\(userid)", handler: { data, response, error in
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
    
    
    func getGroupInfo(groupId:String) {
        self.sendGetRequest("http://rumapi.herokuapp.com/group/\(groupId)", handler: nil)
    }
    
    func quickDoTask(groupId:String, creatorId:String, taskName:String) {
        self.sendPostRequest("http://rumapi.herokuapp.com/group/\(groupId)/task", body: ["groupId":groupId, "creator":creatorId, "title":taskName], handler: {data, response, error in
            guard let response = response as? NSHTTPURLResponse where response.statusCode == 200 else {
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as? [String:AnyObject] {
                    if let taskId = json["taskId"] as? String {
                        self.sendPostRequest("http://rumapi.herokuapp.com/group/\(groupId)/complete/\(taskId)", body: ["groupId":groupId, "taskId":taskId, "userId":creatorId], handler: {data, response, error in
                            if let response = response as? NSHTTPURLResponse {
                                print(response)
                            }
                            
                            do {
                                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as? [String:AnyObject] {
                                    print(json)
                                }
                            } catch {
                                
                            }
                        })
                    }
                }
            } catch {
            }
        })
    }
    
    func createTask(groupId:String, creatorId:String, taskName:String) {
        self.sendPostRequest("http://rumapi.herokuapp.com/group/\(groupId)/task", body: ["groupId":groupId, "creator":creatorId, "title":taskName], handler: {data, response, error in
            // Do something
        })
    }
    
    func completeTask(groupId:String, taskId:String, userId:String) {
        self.sendPostRequest("http://rumapi.herokuapp.com/group/\(groupId)/complete/:taskId", body: ["groupId":groupId, "taskId":taskId, "userId":userId], handler: {data, response, error in
            // Do something
        })
    }
    
    // Gets the last task that was completed in this group
    func getLastTask(groupId:String) {
        self.sendGetRequest("http://rumapi.herokuapp.com/group/\(groupId)/completed?limit=1", handler: { data, response, error in
            
            if let response = response as? NSHTTPURLResponse where response.statusCode == 200 {
                var responseData = [String:AnyObject]()
                if let jsonArray = try? NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as? [AnyObject] {
                    if let json = jsonArray![0] as? [String:String] {
                        responseData["data"] = json
                        self.sendGetRequest("http://rumapi.herokuapp.com/user/\(json["creator"]!)", handler: { data, response, error in
                            print(response)
                            if let user = try? NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as? [String:AnyObject] {
                                responseData["user"] = user
                                NSNotificationCenter.defaultCenter().postNotificationName(Constants.LAST_TASK, object: nil, userInfo: responseData)
                            }
                        })
                    }
                }
            }
        })
    }
    
    
    // MARK: - GET/POST
    private func sendGetRequest(endpoint:String, handler:((NSData?, NSURLResponse?, NSError?) -> Void)?) {
        self.sendRequest(endpoint, body: [:], method: "GET", useJSON: false, handler: handler)
    }
    
    private func sendPostRequest(endpoint:String, body:[String: AnyObject], handler:((NSData?, NSURLResponse?, NSError?) -> Void)?) {
        self.sendRequest(endpoint, body: body, method: "POST", useJSON: true, handler: handler)
    }
    
    private func sendRequest(endpoint:String, body:[String: AnyObject], method:String, useJSON:Bool, handler:((NSData?, NSURLResponse?, NSError?) -> Void)?) {
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
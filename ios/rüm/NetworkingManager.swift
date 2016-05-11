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
        static let GROUP_DOESNT_EXIST = "GROUP_DOESNT_EXIST"
        static let USER_CREATED_GROUP = "USER_CREATED_GROUP"
        static let CHECK_USER_EXISTS = "CHECK_USER_EXISTS"
        static let UPDATE_TODO = "UPDATE_TODO"
        static let LAST_TASK = "LAST_TASK"
        static let GROUP_DATA = "GROUP_DATA"
        static let GET_USER_INFO = "GET_USER_INFO"
    }
    
    
    // MARK: - First time flows
    func registerUser(userid:String, deviceToken:String?, firstName:String, lastName:String, imageUrl:String) {
        let registerEndpoint = "/register"
        var bodyDict = ["userId":userid, "accessToken":FBSDKAccessToken.currentAccessToken().tokenString, "firstName":firstName, "lastName":lastName, "photo":imageUrl]
        
        if let deviceId = deviceToken {
            bodyDict["deviceId"] = deviceId
        }
        
        self.sendPostRequest(registerEndpoint, body: bodyDict, handler: nil)
    }
    
    func checkUser(userid:String) {
        
        let endpoint = "/login"
        var data = ["userId":userid, "accessToken":FBSDKAccessToken.currentAccessToken().tokenString]
        if let deviceToken = NSUserDefaults.standardUserDefaults().stringForKey(NotificationManager.Constants.DEVICE_TOKEN) {
            data["deviceToken"] = deviceToken
        }
        
        self.sendPostRequest(endpoint, body: data, handler: { data, response, error in
            
            var userInfo = [String: AnyObject]()
            if let response = response as? NSHTTPURLResponse {
                userInfo["response"] = response
            }
            
            if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) {
                userInfo["data"] = json
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.CHECK_USER_EXISTS, object: nil, userInfo: userInfo)
        })
    }
    
    func createGroup(groupname:String) {
        let endpoint = "/group"
        let jsonArray = ["name":groupname]
        self.sendPostRequest(endpoint, body: jsonArray, handler: { data, response, error in
            
            self.reportErrors(endpoint, data: data, response: response, error: error)
            
            guard let response = response as? NSHTTPURLResponse where response.statusCode == 200 else {
                return
            }
            
            guard let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String: AnyObject] else {
                return
            }
            
            guard let groupId = json!["groupId"] as? String else {
                return
            }
            
            NSUserDefaults.standardUserDefaults().setValue(groupId, forKey: MainViewController.Constants.GROUP_ID)
            
            self.generateCodeForGroup(groupId)
            
        })
    }
    
    func generateCodeForGroup(groupid:String) {
        let endpoint = "/invite"
        self.sendPostRequest(endpoint, body: ["groupId":groupid], handler: { data, response, error in
            
            self.reportErrors(endpoint, data: data, response: response, error: error)
            
            guard let response = response as? NSHTTPURLResponse where response.statusCode == 200 else {
                return
            }
            
            guard let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String: AnyObject] else {
                return
            }
            
            NSUserDefaults.standardUserDefaults().setValue(json!["code"]!, forKey: "code")
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.USER_CREATED_GROUP, object: nil, userInfo: ["code":json!["code"]!])
        })
    }
    
    func joinUserToGroup(userid:String, groupCode:String) {
        
        let endpoint = "/invite/\(groupCode)"
        
        self.sendGetRequest(endpoint, handler: { data, response, error in
            
            self.reportErrors(endpoint, data: data, response: response, error: error)
            
            guard let httpresponse = response as? NSHTTPURLResponse where httpresponse.statusCode == 200 else {
                var userInfo = [String:Int]()
                if let response = response as? NSHTTPURLResponse {
                    userInfo["status"] = response.statusCode
                }
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.GROUP_DOESNT_EXIST, object: nil, userInfo: userInfo)
                return
            }
            
            guard let json = try? NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as? [String:AnyObject] else {
                return
            }
            
            guard let groupId = json!["groupId"] as? String else {
                return
            }
            
            let endpoint2 = "/group/\(groupId)"
            self.sendRequest(endpoint2, body: ["userId":userid], method: "PUT", useJSON: true, handler: { data, response, error in
                
                self.reportErrors(endpoint2, data: data, response: response, error: error)
                
                if let response = response as? NSHTTPURLResponse {
                    NSUserDefaults.standardUserDefaults().setValue(groupId, forKey: MainViewController.Constants.GROUP_ID)
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.USER_JOINED_GROUP, object: nil, userInfo: ["response":response])
                }
            })
        })
    }
    
    // MARK: - Login
    func login(userid:String, groupid:String) {
        let endpoint = "/login"
        self.sendPostRequest(endpoint, body: ["userId":userid, "accessToken":FBSDKAccessToken.currentAccessToken().tokenString], handler: {data, response, error in
            self.reportErrors(endpoint, data: data, response: response, error: error)
            NetworkingManager.sharedInstance.getGroupInfo(groupid)
            NetworkingManager.sharedInstance.generateCodeForGroup(groupid)
            NetworkingManager.sharedInstance.getLastTask(groupid)
            NetworkingManager.sharedInstance.getIncompleteTasks(groupid)
        })
    }
    
    // MARK: - Group Info
    func getGroupInfo(groupId:String) {
        self.sendGetRequest("/group/\(groupId)", handler: nil)
    }
    
    func getGroupForData(groupId:String) {
        let endpoint = "/group/\(groupId)"
        self.sendGetRequest(endpoint, handler: { data, response, error in
            
            self.reportErrors(endpoint, data: data, response: response, error: error)
            
            guard let json = try? NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as? [String:AnyObject] else {
                return
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.GROUP_DATA, object: nil, userInfo: ["members":json!["members"]!])
        })
    }
    
    func getUserInfo(userId:String) {
        let endpoint = "/user/\(userId)"
        self.sendGetRequest(endpoint, handler: {data, response, error in
            self.reportErrors(endpoint, data: data, response: response, error: error)
            
            guard let json = try? NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as? [String:AnyObject] else {
                return
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.GET_USER_INFO, object: nil, userInfo: json)
        })
    }
    
    // MARK: - Tasks
    func quickDoTask(groupId:String, creatorId:String, taskName:String) {
        let endpoint = "/group/\(groupId)/task"
        self.sendPostRequest(endpoint, body: ["groupId":groupId, "title":taskName], handler: {data, response, error in
            
            self.reportErrors(endpoint, data: data, response: response, error: error)
            
            guard let response = response as? NSHTTPURLResponse where response.statusCode == 200 else {
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as? [String:AnyObject] {
                    if let taskId = json["taskId"] as? String {
                        
                        
                        // send GA events
                        // label = "taskCompleter : taskId"
                        GA.sendEvent("task", action: "complete-quick", label: "\(creatorId) : \(taskId)", value: nil)
                        
                        self.sendPostRequest("/group/\(groupId)/complete/\(taskId)", body: ["groupId":groupId, "taskId":taskId, "userId":creatorId], handler: nil)
                    }
                }
            } catch {
            }
        })
    }
    
    func createTask(groupId:String, taskName:String) {
        self.sendPostRequest("/group/\(groupId)/task", body: ["groupId":groupId, "title":taskName], handler: nil)
    }
    
    func getIncompleteTasks(groupId:String) {
        let endpoint = "/group/\(groupId)/task"
        self.sendGetRequest(endpoint, handler: { data, response, error in
            
            self.reportErrors(endpoint, data: data, response: response, error: error)
            
            guard let response = response as? NSHTTPURLResponse where response.statusCode == 200 else {
                return
            }
            
            guard let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [[String:AnyObject]] else {
                return
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.UPDATE_TODO, object: nil, userInfo: ["data":json!])
        })
    }
    
    func assignTask(groupId:String, taskId:String, assignToId:String?) {
        let endPoint = "/group/\(groupId)/task/\(taskId)"
        self.sendRequest(endPoint, body: ["assignedTo":assignToId ?? ""], method: "PUT", useJSON: true, handler: nil)
    }
    
    func deleteTask(groupId:String, taskId:String) {
        let endpoint = "/group/\(groupId)/task/\(taskId)"
        self.sendRequest(endpoint, body: [:], method: "DELETE", useJSON: false, handler: { data, response, error in
            self.reportErrors(endpoint, data: data, response: response, error: error)
            self.getIncompleteTasks(NSUserDefaults.standardUserDefaults().stringForKey(MainViewController.Constants.GROUP_ID)!)
        })
    }
    
    func completeTask(groupId:String, taskId:String, userId:String) {
        let endpoint = "/group/\(groupId)/complete/\(taskId)"
        self.sendPostRequest(endpoint, body: ["groupId":groupId, "taskId":taskId, "userId":userId], handler: {data, response, error in
            self.reportErrors(endpoint, data: data, response: response, error: error)
            self.getIncompleteTasks(NSUserDefaults.standardUserDefaults().stringForKey(MainViewController.Constants.GROUP_ID)!)
        })
    }
    
    // Gets the last task that was completed in this group
    func getLastTask(groupId:String) {
        let endpoint = "/group/\(groupId)/completed?limit=1"
        self.sendGetRequest(endpoint, handler: { data, response, error in
            
            self.reportErrors(endpoint, data: data, response: response, error: error)
            
            if let response = response as? NSHTTPURLResponse where response.statusCode == 200 {
                var responseData = [String:AnyObject]()
                if let jsonArray = try? NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as? [AnyObject] {
                    guard let jsonArray = jsonArray where jsonArray.count > 0 else {
                        NSNotificationCenter.defaultCenter().postNotificationName(Constants.LAST_TASK, object: nil, userInfo: [:])
                        return
                    }
                    if let json = jsonArray[0] as? [String:AnyObject] {
                        responseData["data"] = json
                        let endpoint2 = "/user/\(json["completer"]!)"
                        self.sendGetRequest(endpoint2, handler: { data, response, error in
                            
                            self.reportErrors(endpoint2, data: data, response: response, error: error)
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
    
    
    // MARK: - Kudos
    func giveKudos(userid:String, number:Int, completionHandler: (() -> Void)?) {
        self.sendPostRequest("/user/\(userid)/kudos", body: ["number":number], handler: nil)
        if (completionHandler != nil) {
            completionHandler!()
        }
    }
    
    
    // MARK: - GET/POST
    private func sendGetRequest(endpoint:String, handler:((NSData?, NSURLResponse?, NSError?) -> Void)?) {
        self.sendRequest(endpoint, body: [:], method: "GET", useJSON: false, handler: handler)
    }
    
    private func sendPostRequest(endpoint:String, body:[String: AnyObject], handler:((NSData?, NSURLResponse?, NSError?) -> Void)?) {
        self.sendRequest(endpoint, body: body, method: "POST", useJSON: true, handler: handler)
    }
    
    private func sendRequest(endpoint:String, body:[String: AnyObject], method:String, useJSON:Bool, handler:((NSData?, NSURLResponse?, NSError?) -> Void)?) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://rumapi.herokuapp.com\(endpoint)")!)
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
                    print("statusCode for \(endpoint) is \(httpStatus.statusCode)")
//                    print("response = \(response)")
                    let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("responseString = \(responseString)")
                }
                
                
            }
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: handlerBlock)
        task.resume()
    }
    
    private func reportErrors(endpoint:String, data:NSData?, response:NSURLResponse?, error:NSError?) {
        // check for fundamental networking error
        guard error == nil && data != nil else {
            print("error=\(error)")
            return
        }
        
        // check for http errors
        if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
            print("statusCode for \(endpoint) is \(httpStatus.statusCode)")
//            print("response = \(response)")
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        
        
    }
}
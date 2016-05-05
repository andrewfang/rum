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
    }
    
    func registerUser(userid:String, deviceToken:String?, firstName:String, lastName:String, imageUrl:String) {
        let registerEndpoint = "/register"
        var bodyDict = ["userId":userid, "accessToken":FBSDKAccessToken.currentAccessToken().tokenString, "firstName":firstName, "lastName":lastName, "photo":imageUrl]
        
        if let deviceId = deviceToken {
            bodyDict["deviceId"] = deviceId
        }
        
        self.sendPostRequest(registerEndpoint, body: bodyDict, handler: nil)
    }
    
    func checkUser(userid:String) {
        self.sendGetRequest("/user/\(userid)", handler: { data, response, error in
            
            self.reportErrors(data, response: response, error: error)
            
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
        let createEndpoint = "/group"
        let jsonArray = ["name":groupname, "userId":userid]
        self.sendPostRequest(createEndpoint, body: jsonArray, handler: { data, response, error in
            
            self.reportErrors(data, response: response, error: error)
            
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
            
            self.generateCodeForGroup(groupId, userid: userid)
            
        })
    }
    
    func generateCodeForGroup(groupid:String, userid:String) {
        self.sendPostRequest("/invite", body: ["groupId":groupid, "inviter":userid], handler: { data, response, error in
            
            self.reportErrors(data, response: response, error: error)
            
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
        
        self.sendGetRequest("/invite/\(groupCode)", handler: { data, response, error in
            
            self.reportErrors(data, response: response, error: error)
            
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
            
            self.sendRequest("/group/\(groupId)", body: ["userId":userid], method: "PUT", useJSON: true, handler: { data, response, error in
                
                self.reportErrors(data, response: response, error: error)
                
                if let response = response as? NSHTTPURLResponse {
                    NSUserDefaults.standardUserDefaults().setValue(groupId, forKey: MainViewController.Constants.GROUP_ID)
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.USER_JOINED_GROUP, object: nil, userInfo: ["response":response])
                }
            })
        })
    }
    
    func getGroupInfo(groupId:String) {
        self.sendGetRequest("/group/\(groupId)", handler: nil)
    }
    
    func quickDoTask(groupId:String, creatorId:String, taskName:String) {
        self.sendPostRequest("/group/\(groupId)/task", body: ["groupId":groupId, "creator":creatorId, "title":taskName], handler: {data, response, error in
            
            self.reportErrors(data, response: response, error: error)
            
            guard let response = response as? NSHTTPURLResponse where response.statusCode == 200 else {
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as? [String:AnyObject] {
                    if let taskId = json["taskId"] as? String {
                        self.sendPostRequest("/group/\(groupId)/complete/\(taskId)", body: ["groupId":groupId, "taskId":taskId, "userId":creatorId], handler: nil)
                    }
                }
            } catch {
            }
        })
    }
    
    func createTask(groupId:String, creatorId:String, taskName:String) {
        self.sendPostRequest("/group/\(groupId)/task", body: ["groupId":groupId, "creator":creatorId, "title":taskName], handler: nil)
    }
    
    func getIncompleteTasks(groupId:String) {
        self.sendGetRequest("/group/\(groupId)/task", handler: { data, response, error in
            
            self.reportErrors(data, response: response, error: error)
            
            guard let response = response as? NSHTTPURLResponse where response.statusCode == 200 else {
                return
            }
            
            guard let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [[String:String]] else {
                return
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.UPDATE_TODO, object: nil, userInfo: ["data":json!])
        })
    }
    
    func deleteTask(groupId:String, taskId:String) {
        self.sendRequest("/group/\(groupId)/task/\(taskId)", body: [:], method: "DELETE", useJSON: false, handler: { data, response, error in
            self.reportErrors(data, response: response, error: error)
            self.getIncompleteTasks(NSUserDefaults.standardUserDefaults().stringForKey(MainViewController.Constants.GROUP_ID)!)
        })
    }
    
    func completeTask(groupId:String, taskId:String, userId:String) {
        self.sendPostRequest("/group/\(groupId)/complete/\(taskId)", body: ["groupId":groupId, "taskId":taskId, "userId":userId], handler: {data, response, error in
            self.reportErrors(data, response: response, error: error)
            self.getIncompleteTasks(NSUserDefaults.standardUserDefaults().stringForKey(MainViewController.Constants.GROUP_ID)!)
        })
    }
    
    // Gets the last task that was completed in this group
    func getLastTask(groupId:String) {
        self.sendGetRequest("/group/\(groupId)/completed?limit=1", handler: { data, response, error in
            
            self.reportErrors(data, response: response, error: error)
            
            if let response = response as? NSHTTPURLResponse where response.statusCode == 200 {
                var responseData = [String:AnyObject]()
                if let jsonArray = try? NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as? [AnyObject] {
                    guard let jsonArray = jsonArray where jsonArray.count > 0 else {
                        return
                    }
                    if let json = jsonArray[0] as? [String:String] {
                        responseData["data"] = json
                        self.sendGetRequest("/user/\(json["creator"]!)", handler: { data, response, error in
                            
                            self.reportErrors(data, response: response, error: error)
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
    
    func giveKudos(userid:String, completionHandler: (() -> Void)?) {
        self.sendPostRequest("/user/\(userid)/kudos", body: [:], handler: nil)
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
    
    private func reportErrors(data:NSData?, response:NSURLResponse?, error:NSError?) {
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
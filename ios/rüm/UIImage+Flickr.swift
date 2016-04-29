//
//  UIImage+Flickr.swift
//  bucketsO
//
//  Created by Andrew Fang on 1/20/16.
//  Copyright © 2016 Alisha Adam. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    // Given a search term, returns an image
    // CAUTION: BLOCKS. You must run this on a separate thread
    @objc class func flickrImageFromQuery(query:String) -> NSData? {
        if let systemImage = UIImage(named: query.lowercaseString) {
            return UIImagePNGRepresentation(systemImage);
        }
        if let urlString = makeSearchURL(query) {
            if let url = NSURL(string: urlString) {
                if let data = NSData(contentsOfURL: url) {
                    return data
                }
            }
        }
        return nil
    }
    
    // Given a search term, returns a flickr url string for search
    private class func makeSearchURL(name:String) -> String? {
        let spaceSearch = self.makeSearchURLWithDelim(name, delim: "%20")
        if (spaceSearch != nil && spaceSearch!.characters.count > 0) {
            return spaceSearch
        } else {
            return self.makeSearchURLWithDelim(name, delim: ",")
        }
    }
    
    
    private class func makeSearchURLWithDelim(name:String, delim:String) -> String? {
        let newName = name.stringByReplacingOccurrencesOfString(" ", withString: delim, options: NSStringCompareOptions.LiteralSearch, range: nil)
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=0305bd4541f12f444960d16eb85e0b8c&tags=" + newName + "&format=json&nojsoncallback=1&per_page=1"
        if let url = NSURL(string:urlString) {
            if let data = NSData(contentsOfURL: url) {
                do {
                    if let json:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        if let photoDict = json["photos"] as? NSDictionary {
                            if let photoArr = photoDict["photo"] as? NSArray {
                                if (photoArr.count < 1) {
                                    return nil
                                }
                                if let imageDict = photoArr[0] as? NSDictionary {
                                    let id = imageDict["id"] as! String
                                    let farmId = imageDict["farm"] as! Int
                                    let serverid = imageDict["server"] as! String
                                    let secret = imageDict["secret"] as! String
                                    return "https://farm\(farmId).staticflickr.com/\(serverid)/\(id)_\(secret).jpg"
                                }
                            }
                        }
                    }
                } catch {
                    // ignore
                }
            }
        }
        return ""
    }
}
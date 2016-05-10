//
//  GA.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/9/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

class GA {
    
    internal static var tracker:GAITracker = GAI.sharedInstance().defaultTracker;
    
    static func registerPageView(pageName: String) {
        tracker.set(kGAIScreenName, value: pageName)
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    static func sendEvent(category: String!, action: String!, label: String?, value: NSNumber?) {
        let event = GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: value)
        tracker.send(event.build() as [NSObject : AnyObject])
        
    }
}

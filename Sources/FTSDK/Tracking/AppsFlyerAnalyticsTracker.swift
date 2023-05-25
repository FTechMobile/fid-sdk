//
//  AppsFlyerAnalyticsTracker.swift
//  FunzyDemoSwift
//
//  Created by Chung Trần on 23/04/2022.
//

import Foundation
import FTSDKCoreKit
import AppsFlyerLib

class AppsFlyerAnalyticsTracker: FTSDKTrackerProtocol {
    
    var isEnableDebug: Bool = false
    
    init() {
        AppsFlyerLib.shared().appleAppID = FTSDKConfig.appId ?? ""
        AppsFlyerLib.shared().appsFlyerDevKey = FTSDKConfig.analyticKey ?? ""
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        AppsFlyerLib.shared().start()
    }
    
    func trackEvent(_ event: String) {
        trackEvent(event, [:])
    }
    
    func trackEvent(_ event: String, _ params: [String : Any]) {
        let eventName = FTSDKTracking.buildName(event, from: "fire", to: "af")
        var trackParams: [String: Any] = [:]
        for (key, value) in params {
            let keyName = FTSDKTracking.buildName(key, from: "fire", to: "af")
            trackParams[keyName] = value
        }
        for (key, value) in FTSDKTracking.getDefaultParams() {
            trackParams[key] = value
        }
        
        // Set default customer Id with FID
        if let userId = FTSDKAppDelegate.instance().getAppData().profile?.sub {
            AppsFlyerLib.shared().customerUserID = userId
        }
        AppsFlyerLib.shared().logEvent(eventName, withValues: trackParams)
    }
}

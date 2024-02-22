//
//  FirebaseDynamicLink.swift
//  
//
//  Created by Nguyen Cuong on 03/07/2023.
//

import FirebaseCore
import FirebaseDynamicLinks

class FirebaseDynamicLink: FTSDKDynamicLinkProtocol {
    
    func handleUniversalLink(_ url: URL, handler: @escaping ((FTSDKDynamicLinkObjectProtocol) -> Void)) -> Bool {
        return DynamicLinks.dynamicLinks()
            .handleUniversalLink(url) { dynamicLink, error in
                // ...
                handler(FTSDKDynamicLinkObject(dynamicLink?.url, payload: nil))
            }
    }
    
    func handleDynamicLink(fromSchemeURL schemeUrl: URL, handler: @escaping ((FTSDKDynamicLinkObjectProtocol) -> Void)) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: schemeUrl) {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            handler(FTSDKDynamicLinkObject(dynamicLink.url, payload: nil))
            return true
        }
        return false
    }
}

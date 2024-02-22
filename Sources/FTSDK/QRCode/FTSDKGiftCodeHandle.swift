//
//  FTSDKGiftCodeHandle.swift
//  FTSDKCoreKit
//
//  Created by Nguyen Cuong on 15/06/2023.
//

import Foundation

@objcMembers
final public class FTSDKGiftCodeHandle: NSObject {
    
    private static let shared: FTSDKGiftCodeHandle = FTSDKGiftCodeHandle()
    public weak var delegate: FTSDKGiftCodeDelegate?
    
    public var giftCode: FTSDKGiftCode?
    
    static public func instance() -> FTSDKGiftCodeHandle {
        return shared
    }
    
    public func handle(_ url: URL) -> Bool {
        let host = url.host ?? ""
        switch(host) {
            case "af":
                if let params = url.queryParameters,
                   let code = params["code"], !code.isEmpty,
                   let content = params["content"] {
                    // Cache gift code, wait sdk init config success
                    self.giftCode = FTSDKGiftCode(code: code, content: content)
                    
                    self.tryFallbackGiftCode()
                    return true
                }
                
                break
            default:
                break
        }
        return false
    }
    
    func tryFallbackGiftCode() {
        if let giftCode = self.giftCode,
           let delegate = self.delegate,
           FTSDKAppDelegate.instance().isSDKReady() {
            
            // Return callback
            delegate.onReceiveGiftCode(giftCode: giftCode)
            // Clear cache
            self.clearGiftCode()
        }
    }
    
    func clearGiftCode() {
        self.giftCode = nil
    }
}

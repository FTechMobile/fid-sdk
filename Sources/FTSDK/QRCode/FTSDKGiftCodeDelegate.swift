//
//  FTSDKQRCodeDelegate.swift
//  FTSDKCoreKit
//
//  Created by Nguyen Cuong on 15/06/2023.
//

import Foundation

@objc public protocol FTSDKGiftCodeDelegate: AnyObject {
    @objc func onReceiveGiftCode(giftCode: FTSDKGiftCode)
}

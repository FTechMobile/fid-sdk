////
////  FTSDKCaptchaProvider.swift
////  
////
////  Created by Nguyen Cuong on 31/10/2022.
////
//
//import Foundation
//import GT3Captcha
//import FTSDKCoreKit
//
//  Created by Nguyen Cuong on 23/03/2023.
//

import Foundation
import FTSDKCoreKit
import UIKit

class FTSDKCaptchaProvider: NSObject, FTSDKCaptchaProtocol, VerifyImageCaptchaDelegate {
    private static let shared: FTSDKCaptchaProvider = FTSDKCaptchaProvider()
    
    public static func instance() -> FTSDKCaptchaProvider {
        return shared
    }
    
    var completed: ((Result<FTSDKCoreKit.FTSDKCaptchaParams?, FTSDKCoreKit.FTSDKError>) -> Void)?
    
    required override init() {
        super.init()
    }
    
    func startCaptcha(completed: ((Result<FTSDKCoreKit.FTSDKCaptchaParams?, FTSDKCoreKit.FTSDKError>) -> Void)?) {
        self.completed = completed
        
        let presenter = VerifyImageCaptchaPresenter()
        presenter.delegate = self
        
        guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
            completed?(.success(nil))
            return
        }
        
        var topController = rootViewController
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }
        topController.present(presenter, animated: true)
    }
    
    func verifyImageCaptcha(didVerifySuccess presenter: FTSDKCoreKit.VerifyImageCaptchaPresenter?) {
        completed?(.success(nil))
    }
    
}

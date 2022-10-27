//
//  FTSDKFacebookAuthenProvider.swift
//  
//
//  Created by ChungTV on 24/10/2022.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import FTSDKCoreKit
import FirebaseAuth

class FTSDKFacebookAuthenProvider: FTSDK3rdAuthProvider {
    
    private var fbLoginManager: LoginManager?
    
    override func authorize(_ context: UIViewController?, completed: @escaping (Result<FTSDK3rdAuthProtocol, FTSDKError>) -> Void) {
        super.authorize(context, completed: completed)
        if fbLoginManager == nil {
            fbLoginManager = LoginManager()
        }
        fbLoginManager?.logOut()
//        let config = LoginConfiguration(permissions: ["public_profile", "email"])
        fbLoginManager?.logIn(permissions: ["public_profile", "email"],
                              from: context, handler: { [weak self] result, error in
            self?.handleFacebookLoginResult(result, error: error)
        })
    }
    
    private func handleFacebookLoginResult(_ loginResult: LoginManagerLoginResult?, error: Error?) {
        if loginResult?.isCancelled ?? false {
            return
        }
        guard let loginResult = loginResult,
              let tokenString = loginResult.token?.tokenString,
              error == nil else {
            self.completed?(.failure(FTSDKError(with: error ?? NSError())))
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
        self.signInWithAppAuth(credential, idToken: tokenString)
    }
}

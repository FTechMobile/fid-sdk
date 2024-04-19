//
//  FTSDKgoogleAuthenProvider.swift
//  
//
//  Created by ChungTV on 24/10/2022.
//

import UIKit
import FTSDKCoreKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class FTSDKGoogleAuthenProvider: FTSDK3rdAuthProvider {
    
    override func authorize(_ context: UIViewController?, completed: @escaping (Result<FTSDK3rdAuthProtocol, FTSDKError>) -> Void) {
        super.authorize(context, completed: completed)
        guard let context = context else { return }
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: context) { [weak self] result, error in
            if let code = (error as? NSError)?.code, code == GIDSignInError.canceled.rawValue {
                return
            }
            if let error = error {
                self?.completed?(.failure(FTSDKError(with: error)))
                return
            }
            
            guard
                let authentication = result?.user,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: authentication.accessToken.tokenString)
            
            self?.signInWithAppAuth(credential, idToken: idToken.tokenString)
        }
//        GIDSignIn.sharedInstance.signIn(with: config, presenting: context) { [weak self] user, error in
//            if let code = (error as? NSError)?.code, code == GIDSignInError.canceled.rawValue {
//                return
//            }
//            if let error = error {
//                self?.completed?(.failure(FTSDKError(with: error)))
//                return
//            }
//            
//            guard
//                let authentication = user?.authentication,
//                let idToken = authentication.idToken
//            else {
//                return
//            }
//            
//            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
//                                                           accessToken: authentication.accessToken)
//            
//            self?.signInWithAppAuth(credential, idToken: idToken)
//        }
    }
    
    override func signOut() {
        GIDSignIn.sharedInstance.signOut()
        super.signOut()
    }
}

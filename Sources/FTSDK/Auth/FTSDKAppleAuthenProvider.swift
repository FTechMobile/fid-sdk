//
//  AppleAuthen.swift
//  
//
//  Created by ChungTV on 24/10/2022.
//

import UIKit
import AuthenticationServices
import FTSDKCoreKit
import FirebaseAuth

class FTSDKAppleAuthenProvider: FTSDK3rdAuthProvider {
    
    override func authorize(_ context: UIViewController?, completed: @escaping (Result<FTSDK3rdAuthProtocol, FTSDKError>) -> Void) {
        self.completed = nil
        if #available(iOS 13, *) {
            super.authorize(context, completed: completed)
            let nonce = randomNonceString()
            currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = (context as? ASAuthorizationControllerPresentationContextProviding)
            authorizationController.performRequests()
        }
    }
}
@available(iOS 13.0, *)
extension FTSDKAppleAuthenProvider: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let appleIDToken = appleIDCredential.identityToken else {
                self.completed?(.failure(FTSDKError(code: FTSDKError.AUTH_3RD_NOTFOUND_TOKEN,
                                                    message: "Unable to fetch identity token")))
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.completed?(.failure(FTSDKError(code: FTSDKError.AUTH_3RD_NOTFOUND_TOKEN,
                                                    message: "Unable to serialize token string from data: \(appleIDToken.debugDescription)")))
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: currentNonce ?? "")
            self.signInWithAppAuth(credential, idToken: idTokenString)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}

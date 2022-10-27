//
//  FTSDK3rdAuthProvider.swift
//  
//
//  Created by ChungTV on 24/10/2022.
//

import UIKit
import FTSDKCoreKit
import FirebaseAuth
import CryptoKit
import CommonCrypto

fileprivate class FTSDK3rdAuthResult: FTSDK3rdAuthProtocol {
    var idToken: String {
        return _idToken
    }
    
    var authToken: String {
        return _authToken
    }
    
    private let _idToken: String
    private let _authToken: String
    
    init(idToken: String, authToken: String) {
        self._idToken = idToken
        self._authToken = authToken
    }
}

class FTSDK3rdAuthProvider: NSObject, FTSDK3rdAuthProviderProtocol {
    
    // Unhashed nonce.
    internal var currentNonce: String?
    internal var completed: ((Result<FTSDK3rdAuthProtocol, FTSDKError>) -> Void)?
    
    required override init() {
        super.init()
    }
    
    func authorize(_ context: UIViewController?, completed: @escaping (Result<FTSDKCoreKit.FTSDK3rdAuthProtocol, FTSDKCoreKit.FTSDKError>) -> Void) {
        self.completed = completed
    }
    
    func signOut() {
       try? Auth.auth().signOut()
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    internal func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    internal func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        if #available(iOS 13.0, *) {
            let hashedData = SHA256.hash(data: inputData)
            let hashString = hashedData.compactMap {
                String(format: "%02x", $0)
            }.joined()
            return hashString
        }
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        inputData.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(inputData.count), &hash)
        }
        let hashString = hash.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }

    internal func signInWithAppAuth(_ cer: AuthCredential, idToken: String) {
        // Sign in with Firebase.
        FTSDKLoadingDialogController.show()
        Auth.auth().signIn(with: cer) { [weak self] (authResult, e) in
            if let error = e {
                FTSDKLoadingDialogController.hide()
                self?.completed?(.failure(FTSDKError(with: error)))
                return
            }
            authResult?.user.getIDTokenForcingRefresh(false, completion: { [weak self] firebaseToken, err in
                if let authToken = firebaseToken {
                    let result = FTSDK3rdAuthResult(idToken: idToken, authToken: authToken)
                    self?.completed?(.success(result))
                } else {
                    FTSDKLoadingDialogController.hide()
                }
            })
            if authResult == nil {
                FTSDKLoadingDialogController.hide()
            }
        }
    }
    
}

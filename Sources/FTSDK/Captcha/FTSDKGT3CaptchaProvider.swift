//
//  FTSDKGT3CaptchaProvider.swift
//
//
//  Created by Nguyen Cuong on 31/10/2022.
//

#if canImport(GT3Captcha)

import Foundation
import GT3Captcha
import FTSDKCoreKit

class FTSDKGT3CaptchaProvider: NSObject, FTSDKCaptchaProtocol {
    private static let shared: FTSDKGT3CaptchaProvider = FTSDKGT3CaptchaProvider()
    
    public static func instance() -> FTSDKGT3CaptchaProvider {
        return shared
    }
    
    private lazy var gt3CaptchaManager: GT3CaptchaManager = {
        let manager = GT3CaptchaManager(api1: nil, api2: nil, timeout: 5.0)
        manager.delegate = self as GT3CaptchaManagerDelegate
        manager.viewDelegate = self as GT3CaptchaManagerViewDelegate
        
        // TODO: Edit with config env
        manager.enableDebugMode(true)
        GT3CaptchaManager.setLogEnabled(true)
        return manager
    }()
    
    var asynTask = GeeTestAsynTask()
    
    required override init() {
        super.init()
        
        registerCaptcha()
    }
    
    private func registerCaptcha() {
        asynTask.api1 = "https://id-dev.ftech.ai/home/registergeetest"
        asynTask.api2 = "http://www.geetest.com/demo/gt/validate-test"
        gt3CaptchaManager.registerCaptcha(withCustomAsyncTask: asynTask, completion: nil);
    }
    
    func startCaptcha(completed: ((Result<FTSDKCaptchaParams?, FTSDKError>) -> Void)?) {
        asynTask.captchaShowConpleted = completed
        gt3CaptchaManager.startGTCaptchaWith(animated: true)
    }
}


extension FTSDKGT3CaptchaProvider: GT3CaptchaManagerDelegate, GT3CaptchaManagerViewDelegate {
    // MARK: GT3CaptchaManagerDelegate
    
    func gtCaptcha(_ manager: GT3CaptchaManager, errorHandler error: GT3Error) {
        print("error code: \(error.code)")
        print("error desc: \(error.error_code) - \(error.gtDescription)")
        
        // Handle errors returned from validation
        if (error.code == -999) {
            // The request was interrupted unexpectedly, usually caused by the user canceling the operation
        } else if (error.code == -10) {
            // Banned during pre-judgment, no graphic verification will be performed
        } else if (error.code == -20) {
            // Try too much
        } else {
            // Network problem or parsing failure, more error codes refer to the development documentation
        }
    }
    
    func gtCaptcha(_ manager: GT3CaptchaManager, didReceiveSecondaryCaptchaData data: Data?, response: URLResponse?, error: GT3Error?, decisionHandler: ((GT3SecondaryCaptchaPolicy) -> Void)) {
        if let error = error {
            print("API2 error: \(error.code) - \(error.error_code) - \(error.gtDescription)")
            decisionHandler(.forbidden)
            return
        }
        
        if let data = data {
            print("API2 repsonse: \(String(data: data, encoding: .utf8) ?? "")")
            decisionHandler(.allow)
            return
        } else {
            print("API2 repsonse: nil")
            decisionHandler(.forbidden)
        }
        decisionHandler(.forbidden)
    }
    
    // MARK: GT3CaptchaManagerViewDelegate
    
    func gtCaptchaWillShowGTView(_ manager: GT3CaptchaManager) {
        print("gtCaptchaWillShowGTView")
    }
    
    func gtCaptchaUserDidCloseGTView(_ manager: GT3CaptchaManager) {
        print("gtCaptchaUserDidCloseGTView")
        asynTask.captchaShowConpleted?(.failure(FTSDKError(code: -1, message: "Captcha not completed")))
    }
}


class GeeTestAsynTask: NSObject {
    fileprivate var captchaShowConpleted: ((Result<FTSDKCaptchaParams?, FTSDKError>) -> Void)?
    fileprivate var api1: String?
    fileprivate var api2: String?
    
    private var validateTask: URLSessionDataTask?
    private var registerTask: URLSessionDataTask?
}

extension GeeTestAsynTask: GT3AsyncTaskProtocol {
    
    func executeRegisterTask(completion: @escaping (GT3RegisterParameter?, GT3Error?) -> Void) {
        /**
         *  Parse and configure validation parameters
         */
        guard let api1 = self.api1,
              let url = URL(string: "\(api1)?ts=\(Date().timeIntervalSince1970)") else {
            print("invalid api1 address")
            let gt3Error = GT3Error(domainType: .extern, code: -9999, withGTDesciption: "Invalid API1 address.")
            completion(nil, gt3Error)
            return
        }
        
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                let gt3Error = GT3Error(domainType: .extern, originalError: error, withGTDesciption: "Request API2 fail.")
                completion(nil , gt3Error)
                return
            }
            
            guard let data = data,
                  let httpResp = response as? HTTPURLResponse, httpResp.statusCode == 200 else {
                let gt3Error = GT3Error(domainType: .extern, code: -9999, withGTDesciption: "Invalid API2 response.")
                completion(nil , gt3Error)
                return
            }
            
            if let param = try? JSONDecoder().decode(API1Response.self, from: data) {
                let registerParameter = GT3RegisterParameter()
                registerParameter.gt = param.gt
                registerParameter.challenge = param.challenge
                registerParameter.success = NSNumber(value: param.success)
                completion(registerParameter, nil)
            } else {
                let gt3Error = GT3Error(domainType: .extern, code: -9999, userInfo: nil, withGTDesciption: "API1 invalid JSON. Origin data: \(String(data: data, encoding: .utf8) ?? "")")
                completion(nil, gt3Error)
            }
        }
        dataTask.resume()
        self.registerTask = dataTask
    }
    
    func executeValidationTask(withValidate param: GT3ValidationParam, completion: @escaping (Bool, GT3Error?) -> Void) {
        if let gtResult = param.result {
            let challenge = gtResult["geetest_challenge"] as! String
            let secCode = gtResult["geetest_seccode"] as! String
            let validate = gtResult["geetest_validate"] as! String
            let result = FTSDKCaptchaParamsImpl(challenge: challenge, validate: validate, secCode: secCode)
            captchaShowConpleted?(.success(result))
            
            completion(true, nil)
        } else {
            captchaShowConpleted?(.failure(FTSDKError(code: -1, message: "Captcha not completed")))
            
            completion(false, nil)
        }
    }
    
    func cancel() {
        self.registerTask?.cancel()
        self.validateTask?.cancel()
    }
}

class FTSDKCaptchaParamsImpl: FTSDKCaptchaParams {
    var challenge: String {
        return _challenge
    }
    var validate: String {
        return _validate
    }
    var secCode: String {
        return _secCode
    }
    
    func dict() -> [String: String] {
        return [
            "X-Geetest-Challenge": _challenge,
            "X-Geetest-Validate": _validate,
            "X-Geetest-Seccode": _secCode,
        ]
    }
    
    private let _challenge: String
    private let _validate: String
    private let _secCode: String
    
    init(challenge: String, validate: String, secCode: String) {
        self._challenge = challenge
        self._validate = validate
        self._secCode = secCode
    }
}

struct API1Response: Codable {
    let success: Bool
    let gt: String
    let challenge: String
    let newCAPTCHA: Bool
    
    enum CodingKeys: String, CodingKey {
        case success = "Success"
        case gt = "Gt"
        case challenge = "Challenge"
        case newCAPTCHA = "NewCaptcha"
    }
}

struct API2Response: Codable {
    var status: String
}

#endif

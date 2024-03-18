//
//  FTSDK.swift
//  
//
//  Created by ChungTV on 21/10/2022.
//

import UIKit
import FTSDKCoreKit
import FBSDKCoreKit
import Firebase
import FirebaseMessaging
import FirebaseAnalytics
import SwiftMessages
import GoogleSignIn

public class FTSDK: NSObject {
    @objc public static func didFinishLaunching(_ application: UIApplication, with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        FTSDKAppDelegate.instance().didFinishLaunching(application, with: launchOptions)
        config()
    }
    
    @objc public static func showQAButton() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            FTSDKBubbleButton.instance.embedOnTopView()
            FTSDKBubbleButton.instance.onTap = {
                FTSDKQA.startShowQA()
            }
        }
    }
    
    @objc public static func hideQAButton() {
        FTSDKBubbleButton.instance.hide()
    }
    
    @objc public static func requestAutoLogin(onUnauthorized: @escaping () -> Void) {
        FTSDKAppDelegate.instance().requestAutoLogin(onUnauthorized: onUnauthorized)
    }
    
    @discardableResult
    @objc public static func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]?) -> Bool {
        // Gift code and apple sign in webview use same deeplink, hanlde gift code first
        if FTSDKGiftCodeHandle.instance().handle(url) {
            return true
        }
        if FTSDKAppDelegate.instance().application(app, open: url, options: options) {
            return true
        }
        
        let source = options?[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        let annotation = options?[UIApplication.OpenURLOptionsKey.annotation]
        if ApplicationDelegate.shared.application(app, open: url, sourceApplication: source, annotation: annotation) {
            return true
        }
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        return false
    }
    
    @discardableResult
    @objc public static func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // Gift code and apple sign in webview use same deeplink, hanlde gift code first
        if FTSDKGiftCodeHandle.instance().handle(url) {
            return true
        }
        
        if FTSDKAppDelegate.instance().application(application,
                                                   open: url,
                                                   sourceApplication: sourceApplication,
                                                   annotation: annotation) {
            return true
        }
        
        if ApplicationDelegate.shared.application(application,open: url,
                                                  sourceApplication: sourceApplication,
                                                  annotation: annotation) {
            return true
        }
        
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        return false
    }
    
    @discardableResult
    @objc public static func `continue`(_ userActivity: NSUserActivity?,
                                        restorationHandler: (([UIUserActivityRestoring]?) -> Void)?) -> Bool {
        return FTSDKAppDelegate.instance().continue(userActivity, restorationHandler: restorationHandler)
    }
    
    private static func config() {
        FTSDKAppDelegate.instance().loadConfig {
            // login with google config
            if let googleConfig = FTSDKConfig.googleServiceInfo {
                // App use dynamic link required use local Google Service plist file, can not use FirebaseOptions
                // let firOptions = FirebaseOptions(googleAppID: googleConfig.GOOGLE_APP_ID, gcmSenderID: googleConfig.GCM_SENDER_ID)
                // firOptions.apiKey = googleConfig.API_KEY
                // firOptions.bundleID = googleConfig.BUNDLE_ID
                // firOptions.clientID = googleConfig.CLIENT_ID
                // firOptions.androidClientID = googleConfig.ANDROID_CLIENT_ID
                // firOptions.projectID = googleConfig.PROJECT_ID
                // firOptions.storageBucket = googleConfig.STORAGE_BUCKET
                // FirebaseApp.configure(options: firOptions)
                // FirebaseApp.configure()
                FTSDKConfig.projectFirebase = googleConfig.PROJECT_ID
            }
            
            // login with facebook config
            if let appID = FTSDKConfig.facebookAppID, let clientID = FTSDKConfig.facebookClientID {
                Settings.shared.appID = appID
                Settings.shared.clientToken = clientID
                Settings.shared.displayName = "FID SDK"
            }
            
            // Add Firebase tracking
            FTSDKTracking.instance().addTracker(FirebaseAnalyticsTracker())
            // Add AppsFlyer tracking
            FTSDKTracking.instance().addTracker(AppsFlyerAnalyticsTracker())
            
            // Setting for DynamicLinks
            FTSDKDynamicLinks.instance().addDynamicLink(FirebaseDynamicLink())
            
            // Run setup for tracking
            FTSDKTracking.configure()
        }
        FTSDKConfig.invoke(provider3rd: FTSDKAppleAuthenProvider.self, type: .apple)
        FTSDKConfig.invoke(provider3rd: FTSDKFacebookAuthenProvider.self, type: .facebook)
        FTSDKConfig.invoke(provider3rd: FTSDKGoogleAuthenProvider.self, type: .google)
        FTSDKConfig.invoke(loading: FTSDKLoadingDialogPresenter.self)
        FTSDKConfig.invoke(header: FTSDKHeaderDialogPresenter.self)
        FTSDKConfig.invoke(dialog: FTSDKCenterDialogPresenter.self)
        FTSDKConfig.invoke(imageLoader: FTSDKImageLoaderImpl.self)
        FTSDKConfig.invoke(captchaProvider: FTSDKCaptchaProvider.self)
        
        FTSDKConfig.firebaseUserPseudoId = Analytics.appInstanceID()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            FTSDKGiftCodeHandle.instance().tryFallbackGiftCode()
            
            FTSDKPurchase.instance().reVerifyPendingTransacions { _ in
                
            }
        }
    }
}

final class FTSDKHeaderDialogPresenter: FTSDKDialogPresenter {
    
    private let presenter: SwiftMessages = {
        let presenter = SwiftMessages()
        presenter.pauseBetweenMessages = 0
        return presenter
    }()
    
    var isVisible: Bool {
        return presenter.current() != nil
    }
    
    required init() {
        
    }
    
    func showDialog(_ contextView: UIView?,
                    with contentView: UIView,
                    config: FTSDKCoreKit.FTSDKDialogConfig,
                    completion: (() -> Void)?) {
        
        //        let messageView = BaseView(frame: .zero)
        //        messageView.installContentView(contentView)
        //
        var _config = SwiftMessages.defaultConfig
        _config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        _config.duration = config.duration == 0 ? .forever : .seconds(seconds: config.duration)
        _config.dimMode = .none
        _config.shouldAutorotate = true
        _config.interactiveHide = true
        _config.presentationStyle = .top
        self.presenter.show(config: _config, view: contentView)
    }
    
    func showDialog(with contentView: UIView, config: FTSDKCoreKit.FTSDKDialogConfig, completion: (() -> Void)?) {
        showDialog(nil, with: contentView, config: config, completion: completion)
    }
    
    func hideDialog(animation: Bool) {
        presenter.hide(animated: animation)
    }
    
    func hideDialog() {
        presenter.hide()
    }
}

final class FTSDKLoadingDialogPresenter: FTSDKDialogPresenter {
    
    private let presenter: SwiftMessages = {
        let presenter = SwiftMessages()
        presenter.pauseBetweenMessages = 0
        return presenter
    }()
    
    var isVisible: Bool {
        return presenter.current() != nil
    }
    
    required init() {
        
    }
    
    func showDialog(_ contextView: UIView?,
                    with contentView: UIView,
                    config: FTSDKCoreKit.FTSDKDialogConfig,
                    completion: (() -> Void)?) {
        if isVisible {
            return
        }
        let messageView = BaseView(frame: .zero)
        let backgroundView = CornerRoundingView()
        backgroundView.cornerRadius = 12
        backgroundView.layer.masksToBounds = true
        messageView.installBackgroundView(backgroundView)
        messageView.backgroundHeight = 100.0
        messageView.configureBackgroundView(width: 150.0)
        messageView.installContentView(contentView)
        
        messageView.layer.shadowColor = UIColor.black.cgColor
        messageView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        messageView.layer.shadowRadius = 4.0
        messageView.layer.shadowOpacity = 0.2
        messageView.layer.masksToBounds = false
        
        var _config = SwiftMessages.defaultConfig
        _config.duration = .forever
        _config.dimMode = .color(color: UIColor(white: 0, alpha: 0.7),
                                 interactive: false)
        _config.presentationContext  = .window(windowLevel: .statusBar)
        _config.interactiveHide = false
        _config.shouldAutorotate = true
        let animator = PhysicsAnimation()
        animator.showDuration = 0.2
        animator.hideDuration = 0.15
        animator.placement = .center
        _config.presentationStyle = .custom(animator: animator)
        self.presenter.show(config: _config, view: messageView)
    }
    
    func showDialog(with contentView: UIView, config: FTSDKCoreKit.FTSDKDialogConfig, completion: (() -> Void)?) {
        showDialog(nil, with: contentView, config: config, completion: completion)
    }
    
    func hideDialog(animation: Bool) {
        presenter.hide(animated: animation)
    }
    
    func hideDialog() {
        presenter.hide()
    }
}

final class FTSDKBottomSheetDialogPresenter: FTSDKDialogPresenter {
    
    private let presenter = SwiftMessages()
    
    var isVisible: Bool {
        return presenter.current() != nil
    }
    
    required init() {
        
    }
    
    func showDialog(_ contextView: UIView?,
                    with contentView: UIView,
                    config: FTSDKCoreKit.FTSDKDialogConfig,
                    completion: (() -> Void)?) {
        
        let bottomSheetView = BaseView(frame: .zero)
        bottomSheetView.respectSafeArea = false
        bottomSheetView.bounceAnimationOffset = 0.0
        let backgroundView = CornerRoundingView()
        backgroundView.cornerRadius = 20.0
        backgroundView.roundedCorners = [.topLeft, .topRight]
        backgroundView.layer.masksToBounds = true
        bottomSheetView.installBackgroundView(backgroundView)
        bottomSheetView.installContentView(contentView)
        var _config = SwiftMessages.defaultConfig
        _config.dimMode = .color(color: UIColor(white: 0, alpha: 0.55),
                                 interactive: config.isDismissWhenTouchOutSide)
        
        _config.presentationStyle = .bottom
        
        _config.duration = .forever
        _config.interactiveHide = true
        if contextView != nil {
            _config.presentationContext = .view(contextView!)
        } else {
            _config.presentationContext = .window(windowLevel: .statusBar)
        }
        let completionListener = { (event: SwiftMessages.Event) in
            switch event {
                case .willShow:
                    break
                case .didShow:
                    completion?()
                case .willHide:
                    break
                case .didHide:
                    break
            }
        }
        _config.eventListeners = [completionListener]
        self.presenter.show(config: _config, view: bottomSheetView)
    }
    
    func showDialog(with contentView: UIView, config: FTSDKCoreKit.FTSDKDialogConfig, completion: (() -> Void)?) {
        showDialog(nil, with: contentView, config: config, completion: completion)
    }
    
    func hideDialog(animation: Bool) {
        presenter.hide(animated: animation)
    }
    
    func hideDialog() {
        presenter.hide()
    }
}

final class FTSDKCenterDialogPresenter: FTSDKDialogPresenter {
    
    private let presenter = SwiftMessages()
    
    var isVisible: Bool {
        return presenter.current() != nil
    }
    
    required init() {
        
    }
    
    func showDialog(_ contextView: UIView?,
                    with contentView: UIView,
                    config: FTSDKCoreKit.FTSDKDialogConfig,
                    completion: (() -> Void)?) {
        
        let messageView = BaseView(frame: .zero)
        let backgroundView = CornerRoundingView()
        backgroundView.cornerRadius = 12
        backgroundView.layer.masksToBounds = true
        messageView.installBackgroundView(backgroundView)
        messageView.configureBackgroundView(width: 280.0)
        
        messageView.installContentView(contentView)
        messageView.layoutMarginAdditions = UIEdgeInsets(top: 0.0,
                                                         left: 24.0,
                                                         bottom: 0.0,
                                                         right: 24.0)
        
        messageView.layer.shadowColor = UIColor.black.cgColor
        messageView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        messageView.layer.shadowRadius = 4.0
        messageView.layer.shadowOpacity = 0.2
        messageView.layer.masksToBounds = false
        
        var _config = SwiftMessages.defaultConfig
        _config.keyboardTrackingView = KeyboardTrackingView()
        _config.keyboardTrackingView?.topMargin = 12
        _config.dimMode = .color(color: UIColor(white: 0, alpha: 0.55),
                                 interactive: config.isDismissWhenTouchOutSide)
        
        let animator = DefaultDialogAnimation()
        animator.showCompletion = completion
        //        animator.hideCompletion = hideCompletion
        _config.presentationStyle = .custom(animator: animator)
        
        _config.duration = .forever
        _config.interactiveHide = false
        _config.presentationContext = .window(windowLevel: .statusBar)
        
        self.presenter.show(config: _config, view: messageView)
    }
    
    func showDialog(with contentView: UIView, config: FTSDKCoreKit.FTSDKDialogConfig, completion: (() -> Void)?) {
        showDialog(nil, with: contentView, config: config, completion: completion)
    }
    
    func hideDialog(animation: Bool) {
        presenter.hide(animated: animation)
    }
    
    func hideDialog() {
        presenter.hide()
    }
    
    private class DefaultDialogAnimation: NSObject, Animator {
        
        var showDuration: TimeInterval = 0.5
        var hideDuration: TimeInterval = 0.15
        
        weak var delegate: AnimationDelegate?
        weak var messageView: UIView?
        weak var containerView: UIView?
        var context: AnimationContext?
        
        var showCompletion: (() -> Void)?
        var hideCompletion: (() -> Void)?
        
        override init() {}
        
        init(delegate: AnimationDelegate) {
            self.delegate = delegate
        }
        
        func show(context: AnimationContext, completion: @escaping AnimationCompletion) {
            NotificationCenter.default.addObserver(self, selector: #selector(adjustMargins),
                                                   name: UIDevice.orientationDidChangeNotification, object: nil)
            install(context: context)
            showAnimation(context: context, completion: completion)
        }
        
        func hide(context: AnimationContext, completion: @escaping AnimationCompletion) {
            // swiftlint:disable:next notification_center_detachment
            NotificationCenter.default.removeObserver(self)
            let view = context.messageView
            self.context = context
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                view.alpha = 1
                view.transform = CGAffineTransform.identity
                completion(true)
                self.hideCompletion?()
            }
            UIView.animate(withDuration: hideDuration,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState],
                           animations: {
                view.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                view.alpha = 0
            },
                           completion: nil)
            CATransaction.commit()
        }
        
        func install(context: AnimationContext) {
            let view = context.messageView
            let container = context.containerView
            messageView = view
            containerView = container
            self.context = context
            view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)
            let constraint = view.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            constraint.priority = .init(200)
            constraint.isActive = true
            NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
            // Important to layout now in order to get the right safe area insets
            container.layoutIfNeeded()
            adjustMargins()
            container.layoutIfNeeded()
        }
        
        @objc func adjustMargins() {
            guard let adjustable = messageView as? MarginAdjustable & UIView,
                  let context = context else { return }
            adjustable.preservesSuperviewLayoutMargins = false
            if #available(iOS 11, *) {
                adjustable.insetsLayoutMarginsFromSafeArea = false
            }
            adjustable.layoutMargins = adjustable.defaultMarginAdjustment(context: context)
        }
        
        func showAnimation(context: AnimationContext, completion: @escaping AnimationCompletion) {
            let view = context.messageView
            view.alpha = 0
            view.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                completion(true)
                self.showCompletion?()
            }
            UIView.animate(withDuration: showDuration,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0,
                           options: .beginFromCurrentState,
                           animations: {
                view.transform = CGAffineTransform.identity
                view.alpha = 1
            },
                           completion: nil)
            CATransaction.commit()
        }
    }
}

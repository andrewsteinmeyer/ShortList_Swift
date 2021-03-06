//
//  AccountManager.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/16/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import FBSDKLoginKit

// Meteor setup
let Meteor = METCoreDataDDPClient(serverURL: NSURL(string: Constants.Meteor.DDPUrl)!)

final class AccountManager: NSObject {
  static func setUpDefaultAccountManager(accountManager: AccountManager) {
    defaultAccountManager = accountManager
  }
  
  static var defaultAccountManager: AccountManager!
  private var managedObjectContext: NSManagedObjectContext!
  
  private var facebookManager = FBSDKLoginManager()
  
  private enum Message: String {
    case FindCurrentUser = "findCurrentUser"
    case SetUserNotificationToken = "setUserNotificationToken"
    case ResetBadgeCount = "removeHistory"
  }
  
  override init() {
    super.init()
    
    Meteor.connect()
    managedObjectContext = Meteor.mainQueueManagedObjectContext
    
    // register observers
    addObservers()
  }
  
  deinit {
    // remove listeners
    removeObservers()
  }
  
  var isUserLoggedIn: Bool {
    return Meteor.userID != nil
  }
  
  var currentUserId: String? {
    return Meteor.userID
  }
  
  var token: String {
    return Meteor.account.resumeToken
  }
  
  var deviceToken: String? {
    didSet {
      guard deviceToken != nil else {
        return
      }
      
      // send device token to Meteor for APNS
      setUserNotificationToken()
    }
  }
  
  var currentUser: User?
  
  // Mark: User account events
  
  func accountDidChange() {
    // user logged out of Meteor
    if Meteor.userID == nil {
      self.signOut()
    }
    // user logged in, request user info from Meteor and save locally
    else {
      findCurrentUser()
    }
  }
  
  // Mark: Meteor server calls
  
  func loginWithEmail(email: String, password: String, completionHandler: METLogInCompletionHandler) {
    Meteor.loginWithEmail(email, password: password, completionHandler: completionHandler)
  }
  
  // login with facebook (server registers user if first time)
  func loginWithFacebook(id: String, token: String, completionHandler: METLogInCompletionHandler) {
    Meteor.loginWithFacebook(id, token: token, completionHandler: completionHandler)
  }
  
  // email and name
  func signUpWithEmail(email: String, password: String, name: String, completionHandler: METLogInCompletionHandler) {
    Meteor.signUpWithEmail(email, password: password, name: name, completionHandler: completionHandler)
  }
  
  // email, name and phone number
  func signUpWithEmail(email: String, password: String, name: String, phone: String, completionHandler: METLogInCompletionHandler) {
    Meteor.signUpWithEmail(email, password: password, name: name, phone: phone, completionHandler: completionHandler)
  }
  
  // just email
  func signUpWithEmail(email: String, password: String, completionHandler: METLogInCompletionHandler) {
    Meteor.signUpWithEmail(email, password: password, completionHandler: completionHandler)
  }
  
  // save device token for APNS
  func setUserNotificationToken() {
    guard let token = deviceToken else {
      return
    }
    
    let params = [ "apn" : token ]
    Meteor.callMethodWithName(Message.SetUserNotificationToken.rawValue, parameters: [params]) {
      userInfo, error in
      
      if error != nil {
        print("server successfully received token: \(token)")
      }
    }
  }
  
  func findCurrentUser() {
    Meteor.callMethodWithName(Message.FindCurrentUser.rawValue, parameters: nil) {
      userInfo, error in
      
      if userInfo != nil {
        let JSONUser = JSON(userInfo!)
        
        let user = User()
        user.emailAddress = JSONUser["email"].string
        user.fullName     = JSONUser["name"].string
        user.rawPhone     = JSONUser["phone"].string
        user.userId       = self.currentUserId
        
        // save user
        self.currentUser = user
      }
    }
  }
  
  func signOut() {
    Meteor.logoutWithCompletionHandler() {
      error in
      
      if error != nil {
        print("Error logging out: \(error?.localizedDescription)")
      }
      else {
        self.logoutFacebook()
        
        // successfully logged out, present sign in
        dispatch_async(dispatch_get_main_queue()) {
          LogInViewController.presentLogInViewController()
        }
      }
    }
  }
  
  func isLoggedInWithFacebook() -> Bool {
    return FBSDKAccessToken.currentAccessToken() != nil
  }
  
  func logoutFacebook() {
    guard isLoggedInWithFacebook() else { return }
    
    self.facebookManager.logOut()
  }
  
  // MARK: Notification observers
  
  private func addObservers() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AccountManager.accountDidChange), name: METDDPClientDidChangeAccountNotification, object: Meteor)
  }
  
  private func removeObservers() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "accountDidChange", object: Meteor)
  }

}
//
//  AccountManager.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/16/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import Meteor

//let Meteor = METCoreDataDDPClient(serverURL: NSURL(string: "ws://localhost:3000/websocket")!)
//let Meteor = METCoreDataDDPClient(serverURL: NSURL(string: "ws://10.0.0.3:3000/websocket")!)
let Meteor = METCoreDataDDPClient(serverURL: NSURL(string: "ws://shortlist.meteor.com/websocket")!)


final class AccountManager: NSObject {
  static func setUpDefaultAccountManager(accountManager: AccountManager) {
    defaultAccountManager = accountManager
  }
  
  static var defaultAccountManager: AccountManager!
  private var managedObjectContext: NSManagedObjectContext!
  
  private enum Message: String {
    case FindCurrentUser = "findCurrentUser"
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
  
  var currentUser: User?
  
  // Mark: User account events
  
  func accountDidChange() {
    // user logged out of Meteor
    if Meteor.userID == nil {
      self.signOut()
    }
    // user logged in, request user info from meteor and save locally
    else {
      findCurrentUser()
    }
  }
  
  // Mark: Meteor server calls
  
  func loginWithEmail(email: String, password: String, completionHandler: METLogInCompletionHandler?) {
    Meteor.loginWithEmail(email, password: password, completionHandler: completionHandler)
  }
  
  func signUpWithEmail(email: String, password: String, completionHandler: METLogInCompletionHandler?) {
    Meteor.signUpWithEmail(email, password: password, completionHandler: completionHandler)
  }
  
  func findCurrentUser() {
    Meteor.callMethodWithName(Message.FindCurrentUser.rawValue, parameters: nil) {
      userInfo, error in
      
      if userInfo != nil {
        let JSONUser = JSON(userInfo!)
        
        let user = User()
        user.emailAddress = JSONUser["email"].string
        
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
        // succesfully logged out, present sign in
        dispatch_async(dispatch_get_main_queue()) {
          SignInViewController.presentSignInViewController()
        }
      }
    }
  }
  
  // MARK: Notification observers
  
  private func addObservers() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "accountDidChange", name: METDDPClientDidChangeAccountNotification, object: Meteor)
  }
  
  private func removeObservers() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "accountDidChange", object: Meteor)
  }

}
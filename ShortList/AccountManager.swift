//
//  AccountManager.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/16/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import Meteor

//let Meteor = METCoreDataDDPClient(serverURL: NSURL(string: "ws://localhost:3000/websocket")!)
let Meteor = METCoreDataDDPClient(serverURL: NSURL(string: "ws://shortlist.meteor.com/websocket")!)

class AccountManager: NSObject {
  static func setUpDefaultAccountManager(accountManager: AccountManager) {
    defaultAccountManager = accountManager
  }
  
  static var defaultAccountManager: AccountManager!
  private var managedObjectContext: NSManagedObjectContext!
  
  override init() {
    Meteor.connect()
    managedObjectContext = Meteor.mainQueueManagedObjectContext
    
    super.init()
    
    // listen for notifications
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
  
  var currentUser: User? {
    get {
      if let userID = Meteor.userID {
        let userObjectID = Meteor.objectIDForDocumentKey(METDocumentKey(collectionName: "users", documentID: userID))
        return (try? managedObjectContext.existingObjectWithID(userObjectID)) as? User
      }
      return nil
    }
    set(user) {
      self.currentUser = user
      
    }
  }
  
  // Mark: Sign in and out
  
  func loginWithEmail(email: String, password: String, completionHandler: METLogInCompletionHandler?) {
    Meteor.loginWithEmail(email, password: password, completionHandler: completionHandler)
  }
  
  func signUpWithEmail(email: String, password: String, completionHandler: METLogInCompletionHandler?) {
    Meteor.signUpWithEmail(email, password: password, completionHandler: completionHandler)
  }
  
  func accountDidChange() {
    if Meteor.userID == nil {
      self.signOut()
    }
  }
  
  func signOut() {
    guard Meteor.userID != nil else {
      return
    }
    
    Meteor.logoutWithCompletionHandler() {
      error in
      
      if error != nil {
        self.currentUser = nil
        
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
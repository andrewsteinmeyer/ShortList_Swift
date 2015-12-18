//
//  AccountManager.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/16/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import Meteor

let Meteor = METCoreDataDDPClient(serverURL: NSURL(string: "ws://localhost:3000/websocket")!)
//let Meteor = METCoreDataDDPClient(serverURL: NSURL(string: "wss://shortlist.meteor.com/websocket")!)

final class AccountManager {
  static func setUpDefaultAccountManager(accountManager: AccountManager) {
    defaultAccountManager = accountManager
  }
  
  static var defaultAccountManager: AccountManager!
  private var managedObjectContext: NSManagedObjectContext!
  
  init() {
    Meteor.connect()
    managedObjectContext = Meteor.mainQueueManagedObjectContext
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
  
  func loginWithEmail(email: String, password: String, completionHandler: METLogInCompletionHandler?) {
    Meteor.loginWithEmail(email, password: password, completionHandler: completionHandler)
  }
  
  func signUpWithEmail(email: String, password: String, completionHandler: METLogInCompletionHandler?) {
    Meteor.signUpWithEmail(email, password: password, completionHandler: completionHandler)
  }
  
  
  func signOut() {
    guard Meteor.userID != nil else {
      return
    }
    
    Meteor.logoutWithCompletionHandler() {
      error in
      
      if error != nil {
        dispatch_async(dispatch_get_main_queue()) {
          self.currentUser = nil
          SignInViewController.presentSignInViewController()
        }
      }
    }
  }

}
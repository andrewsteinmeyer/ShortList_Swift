//
//  AppDelegate+Push.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/27/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

extension AppDelegate {
  
  private enum Category: String {
    case Invite = "invite"
  }
  
  private enum Action: String {
    case More = "more-info"
  }
  
  //MARK: Handle notification registration
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    // convert device token to string and store on Account Manager
    let deviceTokenString = deviceToken.hexString()
    AccountManager.defaultAccountManager.deviceToken = deviceTokenString
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    print("failed to register for remote notifications: \(error)")
  }
  
  //MARK: Handle remote notifications
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    print("received remote notification")
    print(userInfo)
  }
  
  func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
    print("received remote notification with action")
    print(identifier)
    print(userInfo)
    
    // needs to be called per Apple Docs
    completionHandler()
  }
  
  func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
    print("received remote notification with response")
    
    let json = JSON(userInfo)
    
    
    if let category = json["aps"]["category"].string {
      switch category {
      case Category.Invite.rawValue:
        print("category: \(category)")
        
        let ejsonString = json["ejson"].string
        
        if let ejsonDict = ejsonString?.convertToDictionary(),
          let eventId = ejsonDict["eventId"] as? String {
          print("eventId: \(eventId)")
          InvitationActivityViewController.presentInvitationActivityControllerForEvent(eventId)
          /*
          if let slideMenuController = AppDelegate.getRootViewController() as? SlideMenuController {
            if let leftVC = slideMenuController.leftViewController as? LeftViewController {
              //leftVC.changeViewController(.Events)
            }
          }
          */
        }
        
      default: ()
        
      }
    }
    
    print(identifier)
    print(responseInfo)
    print(userInfo)
    
    // needs to be called per Apple Docs
    completionHandler()
  }
  
  //MARK: APNS categories
  
  func registerEventInviteNotificationCategory() -> UIMutableUserNotificationCategory {
    // accept action
    let acceptAction = UIMutableUserNotificationAction()
    acceptAction.title = "Accept"
    acceptAction.identifier = "accept"
    acceptAction.activationMode = .Background
    acceptAction.behavior = .Default
    acceptAction.authenticationRequired = false
    
    // decline action
    let declineAction = UIMutableUserNotificationAction()
    declineAction.title = "Decline"
    declineAction.identifier = "decline"
    declineAction.activationMode = .Background
    declineAction.behavior = .Default
    declineAction.authenticationRequired = false
    
    // more info action
    let moreAction = UIMutableUserNotificationAction()
    moreAction.title = "More Info"
    moreAction.identifier = "more-info"
    moreAction.activationMode = .Foreground
    moreAction.behavior = .Default
    moreAction.authenticationRequired = false
    
    // invite category
    let inviteCategory = UIMutableUserNotificationCategory()
    inviteCategory.identifier = "invite"
    inviteCategory.setActions([acceptAction, moreAction], forContext: .Minimal)
    inviteCategory.setActions([acceptAction, moreAction, declineAction], forContext: .Default)
    
    return inviteCategory
  }
  
  func registerEventMessageNotificationCategory() -> UIMutableUserNotificationCategory {
    // reply action
    let replyAction = UIMutableUserNotificationAction()
    replyAction.title = "Reply"
    replyAction.identifier = "reply-identifier"
    replyAction.activationMode = .Background
    replyAction.behavior = .TextInput
    replyAction.authenticationRequired = false
    
    // message category
    let messageCategory = UIMutableUserNotificationCategory()
    messageCategory.identifier = "message"
    messageCategory.setActions([replyAction], forContext: .Minimal)
    
    return messageCategory
  }
  
  
  //MARK: Register notification categories
  
  func registerForPushNotifications() {
    
    let inviteCategory = registerEventInviteNotificationCategory()
    let messageCategory = registerEventMessageNotificationCategory()
    
    // register for the types of alerts that we are interested in
    let settings = UIUserNotificationSettings(forTypes: [.Sound, .Badge, .Alert], categories: [inviteCategory, messageCategory])
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    
    // register for remote notifications from APNS
    UIApplication.sharedApplication().registerForRemoteNotifications()
  }
  
}

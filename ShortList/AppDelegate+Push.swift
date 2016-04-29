//
//  AppDelegate+Push.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/27/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

// MARK: - Apple Push Notifications

struct Push {
  
  enum Message: String {
    case ResetBadgeCount = "removeHistory"
  }
  
  enum Category: String {
    case Invite = "eventInvite"
    case Message = "newMessage"
  }
  
  enum Action: String {
    case Accept = "accept"
    case Decline = "decline"
    case Reply = "reply"
    case MoreInfo = "more-info"
  }
  
}

//MARK: - AppDelegate Extension for APNS

extension AppDelegate {
  
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
    print("received remote notification with action: when is this called??")
    print(identifier)
    print(userInfo)
    
    // needs to be called per Apple Docs
    completionHandler()
  }
  
  func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
    print("received remote notification with response")
    
    let json = JSON(userInfo)
    
    if let categoryString = json["aps"]["category"].string,
      category = Push.Category(rawValue: categoryString),
      ejsonString = json["ejson"].string,
      ejsonDict = ejsonString.convertToDictionary(),
      identifier = identifier,
      action = Push.Action(rawValue: identifier) {
      
      switch category {
      case .Invite:
        switch action {
        case .MoreInfo:
          guard let eventId = ejsonDict["eventId"] as? String else {
            break
          }
          
          // display invitation activity page for the event
          InvitationActivityViewController.presentInvitationActivityControllerForEvent(eventId)
          
        case .Accept:
          guard let invitationId = ejsonDict["invitationId"] as? String else {
            break
          }
          
          // record that user accepted the invitation
          MeteorEventService.sharedInstance.setInvitationResponse([invitationId, "accepted"]) {
            result, error in
            
            if error != nil {
              print("error: \(error?.localizedDescription)")
            } else {
              print("success: event invitation accepted")
            }
          }
          
        default: ()
        }
      
      case .Message:
        switch action {
        case .Reply:
          guard let eventId = ejsonDict["eventId"] as? String else {
            break
          }
          
          if let response = responseInfo[UIUserNotificationActionResponseTypedTextKey],
            responseText = response as? String {
              
              MeteorEventService.sharedInstance.sendEventMessage([eventId, responseText]) {
                result, error in
                
                if error != nil {
                  print("error: \(error?.localizedDescription)")
                } else {
                  print("success: event message sent")
                }
              }
          }
          
        default: ()
        }
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
    acceptAction.identifier = Push.Action.Accept.rawValue
    acceptAction.activationMode = .Background
    acceptAction.behavior = .Default
    acceptAction.authenticationRequired = false
    
    // decline action
    let declineAction = UIMutableUserNotificationAction()
    declineAction.title = "Decline"
    declineAction.identifier = Push.Action.Decline.rawValue
    declineAction.activationMode = .Background
    declineAction.behavior = .Default
    declineAction.authenticationRequired = false
    
    // more info action
    let moreAction = UIMutableUserNotificationAction()
    moreAction.title = "More Info"
    moreAction.identifier = Push.Action.MoreInfo.rawValue
    moreAction.activationMode = .Foreground
    moreAction.behavior = .Default
    moreAction.authenticationRequired = false
    
    // invite category
    let inviteCategory = UIMutableUserNotificationCategory()
    inviteCategory.identifier = Push.Category.Invite.rawValue
    inviteCategory.setActions([acceptAction, moreAction], forContext: .Minimal)
    inviteCategory.setActions([acceptAction, moreAction, declineAction], forContext: .Default)
    
    return inviteCategory
  }
  
  func registerEventMessageNotificationCategory() -> UIMutableUserNotificationCategory {
    // reply action
    let replyAction = UIMutableUserNotificationAction()
    replyAction.title = "Reply"
    replyAction.identifier = Push.Action.Reply.rawValue
    replyAction.activationMode = .Background
    replyAction.behavior = .TextInput
    replyAction.authenticationRequired = false
    
    // message category
    let messageCategory = UIMutableUserNotificationCategory()
    messageCategory.identifier = Push.Category.Message.rawValue
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
  
  //MARK: Badge reset
  
  func resetBadgeCount() {
    guard let userId = Meteor.userID else { return }
    
    // clear badge on server
    Meteor.callMethodWithName(Push.Message.ResetBadgeCount.rawValue, parameters: [ userId ]) {
      userInfo, error in
      
      if error == nil {
        print("successfully reset badge count")
        // set local count to zero to clear badge
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
      }
    }
    
  }
  
}

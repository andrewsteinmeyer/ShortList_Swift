//
//  AppDelegate.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/14/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import Contacts
import GoogleMaps
import GooglePlaces
import Fabric
import Crashlytics
import FLEX
import FBSDKCoreKit
import FBSDKLoginKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  // used to import contacts from phone
  var contactStore = CNContactStore()
  
  // used with google location picker
  let googleMapsApiKey = Constants.GoogleMaps.ApiKey
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // setup appearance and menu
    self.setAppearance()
    
    //FLEXManager.sharedManager().showExplorer()
    Fabric.with([Crashlytics.self])
    
    // set up account manager and establish connection to Meteor
    AccountManager.setUpDefaultAccountManager(AccountManager())
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "METShouldLogDDPMessages")
    
    // set up google services
    GMSServices.provideAPIKey(googleMapsApiKey)
    GMSPlacesClient.provideAPIKey(googleMapsApiKey)
    
    // set up facebook login
    return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // activate Facebook
    FBSDKAppEvents.activateApp()
    
    // reset badge count when user re-opens app from background state
    self.resetBadgeCount()
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // logout facebook
    FBSDKLoginManager.init().logOut()
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    
    // call when user successfully logs in with facebook and returning to application
    return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
  }
  
  // MARK: Class functions
  
  class func getAppDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
  }
  
  class func getRootViewController() -> UIViewController? {
    return getAppDelegate().window?.rootViewController
  }
  
  // MARK: Private functions
  
  private func setAppearance() {
    UINavigationBar.appearance().tintColor = Theme.NavigationBarTintColor.toUIColor()
    UINavigationBar.appearance().barTintColor = Theme.NavigationBarBackgroundColor.toUIColor()
    UINavigationBar.appearance().translucent = false
  }
  
  // MARK: Helpers
  
  func showMessage(message: String) {
    let alertController = UIAlertController(title: "ShortList", message: message, preferredStyle: UIAlertControllerStyle.Alert)
    let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
    }
    
    alertController.addAction(dismissAction)
    
    /*
    let pushedViewControllers = (self.window?.rootViewController as! UINavigationController).viewControllers
    let presentedViewController = pushedViewControllers[pushedViewControllers.count - 1]
    
    presentedViewController.presentViewController(alertController, animated: true, completion: nil)
    */
    
    // TODO: Think this is correct, but test when we add back the contacts picker
    // The old code commented out above only accounted for presenting over a nav controller,
    // but topViewController looks at all types of controllers
    // If topViewController works, then delete the old code that is commented out above
    UIApplication.topViewController()?.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
    let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
    
    switch authorizationStatus {
    case .Authorized:
      completionHandler(accessGranted: true)
      
    case .Denied, .NotDetermined:
      self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
        if access {
          completionHandler(accessGranted: access)
        }
        else {
          if authorizationStatus == CNAuthorizationStatus.Denied {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
              self.showMessage(message)
            })
          }
        }
      })
      
    default:
      completionHandler(accessGranted: false)
    }
  }


}


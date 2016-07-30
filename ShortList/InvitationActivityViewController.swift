//
//  InvitationActivityViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/20/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import WebKit


// OLD WAY: Brings up Invitation information in webview

class InvitationActivityViewController: UIViewController {
  
  var url: String!
  var webView: WKWebView!
  
  override func loadView() {
    super.loadView()
    self.webView = WKWebView()
    self.view = self.webView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let targetURL = NSURL(string: url)
    let request = NSURLRequest(URL: targetURL!)
    webView.loadRequest(request)
  }
  
  //MARK: - Static methods
  
  static func presentInvitationActivityControllerForEvent(eventId: String) {
    
    // find the reveal controller
    if let revealViewController = AppDelegate.getRootViewController() as? SWRevealViewController {

      // query event info
      MeteorEventService.sharedInstance.findEventInfoById([eventId]) { result, error in
        dispatch_async(dispatch_get_main_queue()) {
          if error != nil {
            print("error: \(error?.localizedDescription)")
          } else {
            print("success: event info found")
            
            let JSONEvent = JSON(result!)
            let eventName = JSONEvent["name"].string ?? ""
            
            // get main storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // setup events page
            let eventsViewController = storyboard.instantiateViewControllerWithIdentifier("EventsViewController") as! EventsViewController
            
            // setup event invitation page
            let invitationVC = storyboard.instantiateViewControllerWithIdentifier("InvitationActivityViewController") as! InvitationActivityViewController
            
            // set name of event
            invitationVC.navigationItem.title = eventName
            
            // load url to request
            invitationVC.url = MeteorRouter.invitationActivityForEventID(eventId)
            
            // populate the navigation controller
            let navVC = EventsNavigationViewController()
            navVC.setViewControllers([eventsViewController, invitationVC], animated: false)
            
            // present the invitation activity page
            revealViewController.pushFrontViewController(navVC, animated: true)
          }
        }
      }
    }
  }
  
}

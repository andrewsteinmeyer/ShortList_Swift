//
//  EventDetailNavigationViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/9/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//


import UIKit

class EventDetailNavigationViewController: UINavigationController {
  
  // MARK: - View Lifecycle
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    // needed for custom presentation
    modalPresentationStyle = UIModalPresentationStyle.Custom
  }
  
  override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)
    
    // needed for custom presentation
    modalPresentationStyle = UIModalPresentationStyle.Custom
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationBarHidden = true
    
    /*
    self.view.clipsToBounds = false
    
    // create cancel button
    let closeButton = UIButton(type: .Custom)
    closeButton.frame = CGRect(x: -15, y: -15, width: 30, height: 30)
    closeButton.layer.cornerRadius = 15
    closeButton.layer.backgroundColor = UIColor.whiteColor().CGColor
    closeButton.setImage(UIImage(named: "cancel-button"), forState: .Normal)
    closeButton.layer.borderWidth = 1.5
    closeButton.layer.borderColor = Theme.EventDetailCancelButtonColor.toUIColor().CGColor
    closeButton.addTarget(self, action: #selector(EventDetailNavigationViewController.closeButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    
    // create clear cancel button to catch tap in greater surface area
    let clearButton = UIButton(type: .Custom)
    clearButton.frame = CGRect(x: -20, y: -20, width: 60, height: 60)
    clearButton.layer.backgroundColor = UIColor.clearColor().CGColor
    clearButton.addTarget(self, action: #selector(EventDetailNavigationViewController.closeButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    
    // add cancel button to view
    self.view.addSubview(closeButton)
    self.view.addSubview(clearButton)
    */
  }
  
  /*
  func closeButtonPressed(sender: UIButton) {
    presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
  }
  */
  
}
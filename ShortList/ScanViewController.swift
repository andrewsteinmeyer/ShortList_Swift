//
//  ScanViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/8/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftQRCode

class ScanViewController: UIViewController {
  
  // initialize scanner
  let scanner = QRCode(autoRemoveSubLayers: false, lineWidth: 4, strokeColor: Theme.QRScannerOutlineColor.toUIColor(), maxDetectedCount: 20)
  
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var modalCancelScanButton: UIButton!
  @IBOutlet weak var cancelScanButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    scanner.prepareScan(view) { (stringValue) -> () in
      print(stringValue)
      let splitString = stringValue.componentsSeparatedByString(":")
      
      let qrType = splitString.first
      let qrValue = splitString.last
      
      guard let type = qrType, id = qrValue else {
        return
      }
      
      switch type {
        case "contact":
          self.saveUserToContacts(id)
        case "list":
          self.saveUserToList(id)
        case "event":
          break
        default: ()
      }
    }
    
    // test scan frame
    scanner.scanFrame = view.bounds
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    scanner.startScan()
  }
  
  
  // MARK: - IBAction
  
  @IBAction func cancelScanButtonDidPress(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func modalCancelScanButtonDidPress(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func modalStartScanButtonDidPress(sender: AnyObject) {
    // hide blur view and show cancel button
    UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseInOut, animations: {
      self.cancelScanButton.hidden = false
      self.blurView.alpha = 0
      },
      completion: nil)
  }
  
  // MARK: - Private methods
  
  private func saveUserToContacts(id: String) {
    
    MeteorContactService.sharedInstance.addUserToContacts([id]) {
      result, error in
      
      dispatch_async(dispatch_get_main_queue()) {
        if let error = error {
          let errorMessage = error.localizedFailureReason
          AppDelegate.getAppDelegate().showMessage(errorMessage!)
        } else {
          self.dismissViewControllerAnimated(true) {
            // navigate to contacts page
            ContactsViewController.presentContactsViewController()
          }
        }
      }
    }
  }
  
  private func saveUserToList(id: String) {
    
    MeteorListService.sharedInstance.addUserToList([id]) {
      result, error in
      
      dispatch_async(dispatch_get_main_queue()) {
        if let error = error {
          let errorMessage = error.localizedFailureReason
          AppDelegate.getAppDelegate().showMessage(errorMessage!)
        } else {
          self.dismissViewControllerAnimated(true) {
            // navigate to contacts page
            JoinedListsViewController.presentJoinedListsViewController()
          }
        }
      }
    }
  }
  
  private func setupAppearance() {
    // set theme colors
    let buttonColor =  Theme.CancelScanButtonBackgroundColor.toUIColor()
    let buttonTextColor = Theme.CancelScanButtonTextColor.toUIColor()
    
    cancelScanButton.backgroundColor = buttonColor
    cancelScanButton.setTitleColor(buttonTextColor, forState: .Highlighted)
    
    // make the view transparent
    self.view.backgroundColor = UIColor.clearColor()
    
  }
}

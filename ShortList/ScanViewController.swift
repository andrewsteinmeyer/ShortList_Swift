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
  
  let scanner = QRCode(autoRemoveSubLayers: false, lineWidth: 4, strokeColor: Theme.QRScannerOutlineColor.toUIColor(), maxDetectedCount: 20)
  
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
          break
        case "list":
          break
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

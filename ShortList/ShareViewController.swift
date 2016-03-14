//
//  ShareViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/13/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//


import UIKit

class ShareViewController: UIViewController {
  
  // MARK: - IBAction
  
  @IBAction func modalCancelScanButtonDidPress(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
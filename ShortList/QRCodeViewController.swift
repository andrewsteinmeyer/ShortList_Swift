//
//  QRCodeViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/14/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftQRCode

class QRCodeViewController: UIViewController {
  
  let scanner = QRCode()
  
  @IBOutlet weak var QRImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  
  var documentID: String!
  var type: String!
  var name: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("doneButtonDidPress"))
    self.navigationItem.rightBarButtonItem = doneButton
    
    self.QRImageView.image = QRCode.generateImage("\(type):\(documentID)", avatarImage: nil)
    self.nameLabel.text = self.name
  }
  
  func doneButtonDidPress() {
    // find the reveal controller
    if let revealVC = AppDelegate.getRootViewController() as? SWRevealViewController {
      revealVC.dismissViewControllerAnimated(true, completion: nil)
    }
  }
}
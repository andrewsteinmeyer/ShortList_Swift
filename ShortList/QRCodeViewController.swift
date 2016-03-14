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
    
    self.QRImageView.image = QRCode.generateImage("\(type):\(documentID)", avatarImage: nil)
    self.nameLabel.text = self.name
  }
}
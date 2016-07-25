//
//  InvitationDetailsViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/24/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class InvitationDetailsViewController: UIViewController {

  @IBOutlet weak var titleTextField: UIMaterialTextField!
  @IBOutlet weak var locationTextField: UIMaterialTextField!
  @IBOutlet weak var detailsTextField: UIMaterialTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTextFields()
  }
  
  private func setupTextFields() {
    let titleColor = UIColor.clearColor()
    
    titleTextField.lineColor = UIColor.clearColor()
    titleTextField.activeTitleColor = titleColor
    titleTextField.inactiveTitleColor = titleColor
    
    locationTextField.activeTitleColor = titleColor
    locationTextField.inactiveTitleColor = titleColor
    
    detailsTextField.activeTitleColor = titleColor
    detailsTextField.inactiveTitleColor = titleColor
  }
}
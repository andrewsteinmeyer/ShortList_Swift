//
//  InvitationSettingsViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/23/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class InvitationSettingsViewController: UIViewController {
  
  @IBOutlet weak var listNameTextField: UIMaterialTextField!
  @IBOutlet weak var minGuestsTextField: UIMaterialTextField!
  @IBOutlet weak var maxGuestsTextField: UIMaterialTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTextFields()
   
  }
  
  private func setupTextFields() {
    let titleColor = UIColor.clearColor()
    let lineColor = Theme.InvitationActionColor.toUIColor()
    
    listNameTextField.lineColor = lineColor
    listNameTextField.activeTitleColor = titleColor
    listNameTextField.inactiveTitleColor = titleColor
    
    minGuestsTextField.activeTitleColor = titleColor
    minGuestsTextField.inactiveTitleColor = titleColor
    
    maxGuestsTextField.activeTitleColor = titleColor
    maxGuestsTextField.inactiveTitleColor = titleColor
  }
  
}


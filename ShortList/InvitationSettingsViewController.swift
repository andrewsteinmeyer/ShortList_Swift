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
  
  private var list: List? {
    didSet {
      // set list name
      listNameTextField.text = list?.name
    }
  }
  
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
    listNameTextField.materialDelegate = self
    
    minGuestsTextField.activeTitleColor = titleColor
    minGuestsTextField.inactiveTitleColor = titleColor
    
    maxGuestsTextField.activeTitleColor = titleColor
    maxGuestsTextField.inactiveTitleColor = titleColor
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      if identifier == "selectList" {
        let selectListViewNavigationVC = segue.destinationViewController as! SelectListNavigationViewController
        let selectListViewController = selectListViewNavigationVC.topViewController as! SelectListViewController
        
        selectListViewController.delegate = self
        selectListViewController.selectedList = self.list
      }
    }
  }
  
  
}

// MARK: UIMaterialTextFieldDelegate

extension InvitationSettingsViewController: UIMaterialTextFieldDelegate {
  
  func materialTextFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField == listNameTextField {
    // stop keyboard from showing
    self.view.endEditing(true)
    
    performSegueWithIdentifier("selectList", sender: nil)
    return false
    }
    
    return true
  }
}

//MARK: - SelectListViewControllerDelegate

extension InvitationSettingsViewController: SelectListViewControllerDelegate {
  
  func selectListViewControllerDidSelectList(list: List) {
    self.list = list
  }
}


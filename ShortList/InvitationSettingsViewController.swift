//
//  InvitationSettingsViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/23/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

protocol InvitationSettingsDelegate: class {
  func invitationSettingsDidSelectList(list: List)
  func invitationSettingsDidSetTitle(title: String)
  func invitationSettingsDidSetMinGuests(minGuests: String)
  func invitationSettingsDidSetMaxGuests(maxGuests: String)
  //func invitationSettingsDidSelectTimer(
}

class InvitationSettingsViewController: InvitationViewController {
  
  @IBOutlet weak var titleTextField: UIMaterialTextField!
  @IBOutlet weak var listNameTextField: UIMaterialTextField!
  @IBOutlet weak var minGuestsTextField: UIMaterialTextField!
  @IBOutlet weak var maxGuestsTextField: UIMaterialTextField!
  
  @IBOutlet weak var thirtyMinuteButton: InvitationSettingButton!
  @IBOutlet weak var oneHourButton: InvitationSettingButton!
  @IBOutlet weak var oneDayButton: InvitationSettingButton!
  @IBOutlet weak var oneWeekButton: InvitationSettingButton!
  
  var timerButtonsArray = [UIButton]()
  
  private enum InvitationTimer: Int {
    case ThirtyMinutes
    case OneHour
    case OneDay
    case OneWeek
    
    private var durationInSeconds: Int {
      switch self {
      case .ThirtyMinutes: return 1800
      case .OneHour:       return 3600
      case .OneDay:        return 86400
      case .OneWeek:       return 604800
      }
    }
  }
  
  // set default to one hour
  private var InvitationDuration: InvitationTimer = .OneHour
  
  private var list: List? {
    didSet {
      guard let list = list else { return }
      
      // set list name
      listNameTextField.text = list.name
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // save timer buttons
    timerButtonsArray = [thirtyMinuteButton, oneHourButton, oneDayButton, oneWeekButton]
    
    setupTextFields()
  }
  
  // populate controller if data exists
  override func populateEventSettings(title: String?, list: List?, minGuests: String?, maxGuests: String?) {
    // set settings
    titleTextField?.text = title
    minGuestsTextField?.text = minGuests
    maxGuestsTextField?.text = maxGuests
    
    // set list
    self.list = list
  }
  
  private func setupTextFields() {
    let titleColor = UIColor.clearColor()
    let lineColor = Theme.InvitationActionColor.toUIColor()
    
    titleTextField.activeTitleColor = titleColor
    titleTextField.inactiveTitleColor = titleColor
    titleTextField.lineColor = titleColor //remove line
    titleTextField.materialDelegate = self
    
    listNameTextField.lineColor = lineColor
    listNameTextField.activeTitleColor = titleColor
    listNameTextField.inactiveTitleColor = titleColor
    listNameTextField.materialDelegate = self
    
    minGuestsTextField.activeTitleColor = titleColor
    minGuestsTextField.inactiveTitleColor = titleColor
    minGuestsTextField.materialDelegate = self
    
    maxGuestsTextField.activeTitleColor = titleColor
    maxGuestsTextField.inactiveTitleColor = titleColor
    maxGuestsTextField.materialDelegate = self
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
  
  private func toggleButtons(sender: UIButton) {
    let unselectedButtons = timerButtonsArray.filter( { $0.tag != sender.tag } ) as! [InvitationSettingButton]
    
    // unselect other buttons
    for button in unselectedButtons {
      button.unselectButton()
    }
   
    // select the correct button
    if let settingsButton = sender as? InvitationSettingButton {
      settingsButton.selectButton()
    }
  }
  
  // MARK: IBAction Methods
  
  @IBAction func didSelectInvitationItem(sender: AnyObject) {
    // user selected duration for invitation
    if let duration = InvitationTimer(rawValue: sender.tag) {
      InvitationDuration = duration
    }
    
    toggleButtons(sender as! UIButton)
  }
  
}

// MARK: UIMaterialTextFieldDelegate

extension InvitationSettingsViewController: UIMaterialTextFieldDelegate {
  
  func materialTextFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField == listNameTextField {
    // stop keyboard from showing
    self.view.endEditing(true)
    
    // present list modal and do not allow text editing
    performSegueWithIdentifier("selectList", sender: nil)
    return false
    }
    
    return true
  }
  
  func materialTextFieldShouldEndEditing(textField: UITextField) -> Bool {
    switch textField {
    case titleTextField:
      delegate?.invitationSettingsDidSetTitle(textField.text!)
    case minGuestsTextField:
      delegate?.invitationSettingsDidSetMinGuests(textField.text!)
    case maxGuestsTextField:
      delegate?.invitationSettingsDidSetMaxGuests(textField.text!)
    default: ()
    }
    
    return true
  }
}

//MARK: - SelectListViewControllerDelegate

extension InvitationSettingsViewController: SelectListViewControllerDelegate {
  
  func selectListViewControllerDidSelectList(list: List) {
    self.list = list
    
    // send list information to delegate
    delegate?.invitationSettingsDidSelectList(list)
  }
}


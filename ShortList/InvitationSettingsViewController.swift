//
//  InvitationSettingsViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/23/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit


class InvitationSettingsViewController: InvitationViewController {
  
  @IBOutlet weak var titleTextField: UIMaterialTextField!
  @IBOutlet weak var listNameTextField: UIMaterialTextField!
  @IBOutlet weak var minGuestsTextField: UIMaterialTextField!
  @IBOutlet weak var maxGuestsTextField: UIMaterialTextField!
  
  @IBOutlet weak var thirtyMinuteButton: InvitationSettingButton!
  @IBOutlet weak var oneHourButton: InvitationSettingButton!
  @IBOutlet weak var oneDayButton: InvitationSettingButton!
  @IBOutlet weak var oneWeekButton: InvitationSettingButton!
  
  var timerButtonsArray: [InvitationSettingButton]!
  
  private var list: List? {
    didSet {
      guard let list = list else { return }
      
      // set list
      self.eventDetails.list = list
      
      // set list name
      listNameTextField.text = list.name
      
      self.delegate?.invitationViewControllerDidUpdateEventDetails()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // save timer buttons
    timerButtonsArray = [thirtyMinuteButton, oneHourButton, oneDayButton, oneWeekButton]
    
    setupTextFields()
    populateEventSettings()
  }
  
  private func setupTextFields() {
    let titleColor = UIColor.clearColor()
    let lineColor = Theme.InvitationActionColor.toUIColor()
    
    //titleTextField.activeTitleColor = titleColor
    //titleTextField.inactiveTitleColor = titleColor
    titleTextField.TitleText.text = "Title"
    titleTextField.lineColor = titleColor //remove line
    titleTextField.materialDelegate = self
    
    //listNameTextField.activeTitleColor = titleColor
    //listNameTextField.inactiveTitleColor = titleColor
    listNameTextField.TitleText.text = "List"
    listNameTextField.lineColor = lineColor //orange line
    listNameTextField.materialDelegate = self
    
    minGuestsTextField.activeTitleColor = titleColor
    minGuestsTextField.inactiveTitleColor = titleColor
    minGuestsTextField.materialDelegate = self
    
    maxGuestsTextField.activeTitleColor = titleColor
    maxGuestsTextField.inactiveTitleColor = titleColor
    maxGuestsTextField.materialDelegate = self
  }
  
  // populate existing settings
  override func populateEventSettings() {
    guard eventDetails != nil else { return }
    
    // set settings
    titleTextField?.text = eventDetails.title
    minGuestsTextField?.text = eventDetails.configuration.minimumGuests
    maxGuestsTextField?.text = eventDetails.configuration.maximumGuests
    
    // set list
    self.list = eventDetails.list
    
    // set timer button
    let selectedButton = timerButtonsArray.filter { $0.tag == eventDetails.invitationDuration.rawValue }
    selectedButton.first?.selectButton()
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
  
  private func toggleTimerButtons(sender: InvitationSettingButton) {
    let unselectedButtons = timerButtonsArray.filter( { $0.tag != sender.tag } )
    
    // unselect other buttons
    for button in unselectedButtons {
      button.unselectButton()
    }
   
    // select the correct timer button
    sender.selectButton()
  }
  
  // MARK: IBAction Methods
  
  @IBAction func didSelectTimerButton(sender: InvitationSettingButton) {
    // user selected duration for invitation
    if let duration = EventDetails.InvitationTimer(rawValue: sender.tag) {
      self.eventDetails.invitationDuration = duration
    }
    
    // update highlighted button
    toggleTimerButtons(sender)
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
      self.eventDetails.title = titleTextField.text!
    case minGuestsTextField:
      self.eventDetails.configuration.minimumGuests = minGuestsTextField.text!
    case maxGuestsTextField:
      self.eventDetails.configuration.maximumGuests = maxGuestsTextField.text!
    default: ()
    }
    
    return true
  }
}

//MARK: - SelectListViewControllerDelegate

extension InvitationSettingsViewController: SelectListViewControllerDelegate {
  
  // list was picked by user
  func selectListViewControllerDidSelectList(list: List) {
    self.list = list
  }
}


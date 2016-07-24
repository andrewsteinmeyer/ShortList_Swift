//
//  InvitationProgressView.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/20/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class InvitationProgressView: UIView {
  
  let buttonRatioToView: CGFloat      = 0.75
  let buttonBorderWidth: CGFloat      = 0.5
  let buttonCornerRadius: CGFloat     = 3.0
  let progressViewWidthRatio: CGFloat = 0.70
  
  var buttonsArray = [UIButton]()
  var progressView: UIProgressView!
  
  var settingsButton: UIButton!
  
  enum ButtonType: Int {
    case Settings
    case Details
    case Send
  }
  
  enum Progress: Float {
    case Settings = 0
    case Details  = 0.5
    case Send     = 1.0
  }
  
  private var firstTime = true
  
  //MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.whiteColor()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    self.backgroundColor = UIColor.whiteColor()
  }
  
  //MARK: - View layout
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    layoutControls()
  }
  
  
  private func layoutControls() {
    let viewWidth = bounds.size.width
    let progressViewWidth = viewWidth * progressViewWidthRatio
    let bufferWidth = (viewWidth - progressViewWidth) / 2
    let yCenter = self.center.y
    
    //turn off autoresizing so that we can set our own constraints
    progressView = UIProgressView(frame: CGRect(x: bufferWidth, y: yCenter, width: progressViewWidth, height: 1.0))
    progressView.translatesAutoresizingMaskIntoConstraints = false
    progressView.trackTintColor = UIColor.lightGrayColor()
    progressView.progressTintColor = Theme.InvitationProgressViewTintColor.toUIColor()
    self.addSubview(progressView)
    
    let margins = self.layoutMarginsGuide
    
    progressView.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor, constant: bufferWidth).active = true
    progressView.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor, constant: -bufferWidth).active = true
    progressView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
  
    // settings button
    let settingsButton = UIButton(type: .Custom)
    settingsButton.translatesAutoresizingMaskIntoConstraints = false
    settingsButton.layer.borderWidth = buttonBorderWidth
    settingsButton.layer.cornerRadius = buttonCornerRadius
    settingsButton.layer.borderColor = UIColor.lightGrayColor().CGColor
    settingsButton.backgroundColor = UIColor.whiteColor()
    settingsButton.addTarget(self, action: #selector(InvitationProgressView.buttonDidPress(_:)), forControlEvents: .TouchUpInside)
    settingsButton.tag = ButtonType.Settings.rawValue
    
    let settingsImage = UIImage(named: "settings-two-cogs")?.imageWithColor(Theme.InvitationProgressButtonColor.toUIColor())
    settingsButton.setImage(settingsImage, forState: .Normal)
    self.addSubview(settingsButton)
    
    // details button
    let detailsButton = UIButton(type: .Custom)
    detailsButton.translatesAutoresizingMaskIntoConstraints = false
    detailsButton.layer.borderWidth = buttonBorderWidth
    detailsButton.layer.cornerRadius = buttonCornerRadius
    detailsButton.layer.borderColor = UIColor.lightGrayColor().CGColor
    detailsButton.backgroundColor = UIColor.whiteColor()
    detailsButton.addTarget(self, action: #selector(InvitationProgressView.buttonDidPress(_:)), forControlEvents: .TouchUpInside)
    detailsButton.tag = ButtonType.Details.rawValue
    
    let detailsImage = UIImage(named: "invite-details")?.imageWithColor(Theme.InvitationProgressButtonColor.toUIColor())
    detailsButton.setImage(detailsImage, forState: .Normal)
    self.addSubview(detailsButton)
    
    if firstTime {
      selectButton(settingsButton)
      firstTime = false
    }
    
    // add buttons to array
    buttonsArray = [settingsButton, detailsButton]
    
    // The buttons should have the same width
    settingsButton.widthAnchor.constraintEqualToAnchor(settingsButton.heightAnchor).active = true
    settingsButton.widthAnchor.constraintEqualToAnchor(detailsButton.widthAnchor).active = true
    
    // The button height is a ratio of the view
    settingsButton.heightAnchor.constraintEqualToAnchor(self.heightAnchor, multiplier: buttonRatioToView).active = true
    detailsButton.heightAnchor.constraintEqualToAnchor(settingsButton.heightAnchor).active = true
    
    // Center everything vertically in the super view
    settingsButton.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
    detailsButton.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
    
    // Position buttons based upon the progress view
    settingsButton.centerXAnchor.constraintEqualToAnchor(margins.leadingAnchor, constant: bufferWidth).active = true
    detailsButton.centerXAnchor.constraintEqualToAnchor(margins.trailingAnchor, constant: -bufferWidth).active = true
    
  }
  
  //MARK: - Button Actions
  
  func buttonDidPress(sender: UIButton) {
    toggleButtonShadows(sender)
    updateProgressBar(sender)
  }
  
  func setInitialButton() {
    selectButton(settingsButton)
  }
  
  private func updateProgressBar(sender: UIButton) {
    if let buttonType = ButtonType(rawValue: sender.tag) {
      switch buttonType {
      case .Settings:
        progressView.progress = Progress.Settings.rawValue
      case .Details:
        progressView.progress = Progress.Details.rawValue
      case .Send:
        progressView.progress = Progress.Send.rawValue
      }
    }
  }
  
  private func toggleButtonShadows(sender: UIButton) {
    let unselectedButtons = buttonsArray.filter( { $0.tag != sender.tag } )
    
    // unselect other buttons
    for button in unselectedButtons {
      print("button: \(button.tag)")
      button.layer.borderWidth = buttonBorderWidth
      button.layer.shadowOpacity = 0
      button.layer.shadowColor = UIColor.whiteColor().CGColor
    }
    
    selectButton(sender)
  }
  
  private func selectButton(button: UIButton) {
    // select button
    button.layer.shadowColor = UIColor.lightGrayColor().CGColor
    button.layer.shadowOpacity = 0.75
    button.layer.shadowRadius = 10
    button.layer.borderWidth = 0
    button.layer.shadowOffset = CGSizeZero
  }
  
}

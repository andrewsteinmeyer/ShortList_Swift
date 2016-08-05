//
//  InvitationManagerCollectionViewHeaderView.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 8/2/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

protocol InvitationManagerDelegate: class {
  func invitationManagerDidAutoInvite()
  func invitationManagerDidCancelAutoInvite()
}

class InvitationManagerCollectionViewHeaderView: UICollectionReusableView {
  
  @IBOutlet weak var autoInviteButton: DesignableButton!
  
  weak var delegate: InvitationManagerDelegate?
  
  enum AutoInviteStatus: Int {
    case NotStarted
    case InProgress
  }
  
  var currentStatus: AutoInviteStatus = .NotStarted
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  @IBAction func didPressAutoInviteButton(sender: AnyObject) {
    switch currentStatus {
    case .NotStarted:
      delegate?.invitationManagerDidAutoInvite()
      currentStatus = .InProgress
      
      autoInviteButton.setTitle("Cancel", forState: .Normal)
      autoInviteButton.backgroundColor = Theme.InvitationCancelButtonColor.toUIColor()
      
    case .InProgress:
      delegate?.invitationManagerDidCancelAutoInvite()
      currentStatus = .NotStarted
      
      autoInviteButton.setTitle("Auto Invite", forState: .Normal)
      autoInviteButton.backgroundColor = Theme.InvitationInviteButtonColor.toUIColor()
    }
    
  }
  
  
  
}
//
//  InvitationSettingButton.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/28/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class InvitationSettingButton: DesignableButton {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  func selectButton() {
    self.backgroundColor = Theme.InvitationSettingsButtonColor.toUIColor()
    self.tintColor = UIColor.whiteColor()
  }
  
  func unselectButton() {
    self.backgroundColor = UIColor.whiteColor()
    self.tintColor = UIColor.darkGrayColor()
  }

}

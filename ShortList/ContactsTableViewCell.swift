//
//  ContactsTableViewCell.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/18/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit

struct ContactsTableViewCellData {
  
  init(name: String?, phone: String?, email: String?) {
    self.name = name ?? ""
    self.phone = phone ?? ""
    self.email = email ?? ""
  }
  var name: String?
  var phone: String?
  var email: String?
}

class ContactsTableViewCell : BaseTableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet weak var phoneLabel: UILabel!
  
  var highlight = false
  let lineLayer = CALayer()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // add a line to the bottom of the section header
    lineLayer.frame = CGRectMake(0, self.bounds.height - 1, self.bounds.width, 0.5)
    lineLayer.backgroundColor = Theme.ContactsTableViewCellSeparatorColor.toUIColor().CGColor
    self.layer.addSublayer(lineLayer)
  }
  
  override func setData(data: Any?) {
    if let data = data as? ContactsTableViewCellData {
      self.nameLabel.text = data.name
      self.phoneLabel.text = data.phone
      self.emailLabel.text = data.email
    }
  }
  
  func toggleHighlight() {
    highlight = !highlight
    
    if highlight {
      let selectedColor = Theme.ContactsTableViewCellBackgroundSelectedColor.toUIColor()
      let selectedTextColor = Theme.ContactsTableViewCellTextSelectedColor.toUIColor()
      let selectedSeparatorColor = Theme.ContactsTableViewCellSeparatorSelectedColor.toUIColor()
      
      self.backgroundColor = selectedColor
      self.nameLabel.textColor = selectedTextColor
      self.phoneLabel.textColor = selectedTextColor
      self.emailLabel.textColor = selectedTextColor
      self.lineLayer.backgroundColor = selectedSeparatorColor.CGColor
    }
    else {
      let textColor = Theme.ContactsTableViewCellTextColor.toUIColor()
      let separatorColor = Theme.ContactsTableViewCellSeparatorColor.toUIColor()
      
      self.backgroundColor = UIColor.whiteColor()
      self.nameLabel.textColor = textColor
      self.phoneLabel.textColor = textColor
      self.emailLabel.textColor = textColor
      self.lineLayer.backgroundColor = separatorColor.CGColor
    }
    
    //self.contentView.backgroundColor = highlight ? selectedColor : UIColor.whiteColor()
  }
}
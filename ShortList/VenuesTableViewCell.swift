//
//  VenuesTableViewCell.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/26/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit

struct VenuesTableViewCellData {
  typealias NamedValues = [String:AnyObject]
  
  init(name: String?, location: NamedValues?) {
    self.name = name ?? ""
    self.location = location ?? nil
    
    if let location = self.location {
      let JSONLocation = JSON(location)
      
      self.address = JSONLocation["address"].string ?? ""
    }
  }
  var name: String?
  var location: NamedValues?
  var address: String?
}

class VenuesTableViewCell : BaseTableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  
  var highlight = false
  let lineLayer = CALayer()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // add a line to the bottom of the section header
    let lineLayer = CALayer()
    lineLayer.frame = CGRectMake(0, self.bounds.height - 1, self.bounds.width, 0.5)
    lineLayer.backgroundColor = UIColor.lightGrayColor().CGColor
    self.layer.addSublayer(lineLayer)
  }
  
  override func setData(data: Any?) {
    if let data = data as? VenuesTableViewCellData {
      self.nameLabel.text = data.name
      self.addressLabel.text = data.address
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
      self.addressLabel.textColor = selectedTextColor
      self.lineLayer.backgroundColor = selectedSeparatorColor.CGColor
    }
    else {
      let textColor = Theme.ContactsTableViewCellTextColor.toUIColor()
      let separatorColor = Theme.ContactsTableViewCellSeparatorColor.toUIColor()
      
      self.backgroundColor = UIColor.whiteColor()
      self.nameLabel.textColor = textColor
      self.addressLabel.textColor = textColor
      self.lineLayer.backgroundColor = separatorColor.CGColor
    }
  }
  
}

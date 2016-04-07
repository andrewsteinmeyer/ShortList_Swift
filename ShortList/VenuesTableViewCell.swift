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
  
  init(name: String?, address: String?) {
    self.name = name ?? ""
    self.address = address ?? ""
  }
  
  var name: String?
  var address: String?
}

class VenuesTableViewCell : BaseTableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  
  var highlight = false
  let lineLayer = CALayer()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // add a custom separator line to the bottom of the cell
    lineLayer.frame = CGRectMake(0, self.bounds.height - 1, self.bounds.width, 0.5)
    lineLayer.backgroundColor = Theme.BaseTableViewCellSeparatorColor.toUIColor().CGColor
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
      let separatorColor = Theme.BaseTableViewCellSeparatorColor.toUIColor()
      
      self.backgroundColor = UIColor.whiteColor()
      self.nameLabel.textColor = textColor
      self.addressLabel.textColor = textColor
      self.lineLayer.backgroundColor = separatorColor.CGColor
    }
  }
  
}

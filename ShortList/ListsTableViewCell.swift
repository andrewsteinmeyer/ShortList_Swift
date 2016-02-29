//
//  ListsTableViewCell.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/23/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit

struct ListsTableViewCellData {
  
  init(name: String?) {
    self.name = name ?? ""
  }
  var name: String?
}

class ListsTableViewCell : BaseTableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  
  var highlight = false
  let lineLayer = CALayer()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // add a line to the bottom of the section header
    lineLayer.frame = CGRectMake(0, self.bounds.height - 1, self.bounds.width, 0.5)
    lineLayer.backgroundColor = Theme.BaseTableViewCellSeparatorColor.toUIColor().CGColor
    self.layer.addSublayer(lineLayer)
  }
  
  override func setData(data: Any?) {
    if let data = data as? ListsTableViewCellData {
      self.nameLabel.text = data.name
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
      self.lineLayer.backgroundColor = selectedSeparatorColor.CGColor
    }
    else {
      let textColor = Theme.ContactsTableViewCellTextColor.toUIColor()
      let separatorColor = Theme.BaseTableViewCellSeparatorColor.toUIColor()
      
      self.backgroundColor = UIColor.whiteColor()
      self.nameLabel.textColor = textColor
      self.lineLayer.backgroundColor = separatorColor.CGColor
    }
  }
  
}

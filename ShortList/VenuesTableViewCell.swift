//
//  VenuesTableViewCell.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/26/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit

struct VenuesTableViewCellData {
  
  init(name: String?) {
    self.name = name ?? ""
  }
  var name: String?
}

class VenuesTableViewCell : BaseTableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  
  var highlight = false
  
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
    }
  }
  
  func toggleHighlight() {
    highlight = !highlight
    
    self.contentView.backgroundColor = highlight ? UIColor.primaryColorLight() : UIColor.whiteColor()
  }
  
}

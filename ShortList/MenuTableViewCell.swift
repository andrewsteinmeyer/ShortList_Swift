//
//  MenuTableViewCell.swift
//  Shortlist
//
//  Created by Andrew Steinmeyer on 12/15/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit

struct MenuTableViewCellData {
    
    init(imageUrl: String, text: String) {
      self.imageUrl = imageUrl
      self.text = text
    }
    var imageUrl: String
    var text: String
}

class MenuTableViewCell : BaseTableViewCell {
  
  @IBOutlet weak var iconView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  
  
  override func awakeFromNib() {
    self.titleLabel?.textColor = UIColor.textColor()
  }
  
  override class func height() -> CGFloat {
    return 44
  }
  
  override func setData(data: Any?) {
    if let data = data as? MenuTableViewCellData {
      self.iconView.image = UIImage(named: data.imageUrl)
      self.titleLabel.text = data.text
    }
  }
}

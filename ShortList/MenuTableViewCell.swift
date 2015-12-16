//
//  DataTableViewCell.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 11/8/15.
//  Copyright © 2015 Yuji Hato. All rights reserved.
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

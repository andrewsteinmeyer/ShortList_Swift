//
//  InviteeTableViewCell.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/25/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

struct InviteeTableViewCellData {
  
  init(name: String?) {
    self.name = name ?? ""
  }
  
  var name: String?
}


class InviteeTableViewCell : BaseTableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  
  override func setData(data: Any?) {
    if let data = data as? InviteeTableViewCellData {
      self.nameLabel.text = data.name
    }
  }
  
}
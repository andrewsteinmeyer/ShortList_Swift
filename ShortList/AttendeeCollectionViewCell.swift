//
//  AttendeeCollectionViewCell.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/3/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

struct AttendeeCollectionViewCellData {
  
  init(name: String?) {
    self.name = name ?? ""
  }
  
  var name: String?
}


class AttendeeCollectionViewCell : UICollectionViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  
  func setData(data: Any?) {
    if let data = data as? AttendeeCollectionViewCellData {
      self.nameLabel.text = data.name
    }
  }
  
}
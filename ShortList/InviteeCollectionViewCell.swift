//
//  InviteeCollectionViewCell.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/3/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

struct InviteeCollectionViewCellData {
  
  init(name: String?, score: String?) {
    self.name = name ?? ""
    self.score = score ?? "0"
  }
  
  var name: String?
  var score: String?
}


class InviteeCollectionViewCell : UICollectionViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var scoreButton: DesignableButton!
  
  func setData(data: Any?) {
    if let data = data as? InviteeCollectionViewCellData {
      self.nameLabel.text = data.name
      self.scoreButton.setTitle(data.score, forState: .Normal)
    }
  }
  
}
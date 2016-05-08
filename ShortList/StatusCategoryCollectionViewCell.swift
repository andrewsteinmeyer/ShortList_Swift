//
//  StatusCategoryCollectionViewCell.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/9/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

struct StatusCategoryCollectionViewCellData {
  
  init(name: String, count: Int) {
    self.name = name
    self.count = count
  }
  
  var name: String!
  var count: Int!
}


class StatusCategoryCollectionViewCell : UICollectionViewCell {
  
  @IBOutlet weak var statusNameLabel: UILabel!
  @IBOutlet weak var statusCountLabel: UILabel!
  
  func setData(data: Any?) {
    if let data = data as? StatusCategoryCollectionViewCellData {
      self.statusNameLabel.text = data.name
      self.statusCountLabel.text = String(data.count)
    }
  }
  
}
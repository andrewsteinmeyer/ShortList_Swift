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
  
  let lineLayer = CALayer()
  let separatorInset: CGFloat = 15.0
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // add a custom separator line to the bottom of the cell
    lineLayer.frame = CGRectMake(separatorInset, self.bounds.height - 1, self.bounds.width - separatorInset, 0.5)
    lineLayer.backgroundColor = Theme.BaseTableViewCellSeparatorColor.toUIColor().CGColor
    self.layer.addSublayer(lineLayer)
  }
  
  func setData(data: Any?) {
    if let data = data as? StatusCategoryCollectionViewCellData {
      self.statusNameLabel.text = data.name
      self.statusCountLabel.text = String(data.count)
    }
  }
  
}
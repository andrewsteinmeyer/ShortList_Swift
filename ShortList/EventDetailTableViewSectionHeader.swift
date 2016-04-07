//
//  EventDetailTableViewSectionHeader.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/6/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class EventDetailTableViewSectionHeader: UITableViewHeaderFooterView {
  
  let lineLayer = CALayer()

  override func layoutSubviews() {
    super.layoutSubviews()
    
    // add a custom separator line to the bottom of the header view cell
    lineLayer.frame = CGRectMake(0, self.bounds.height - 1, self.bounds.width, 0.5)
    lineLayer.backgroundColor = Theme.BaseTableViewCellSeparatorColor.toUIColor().CGColor
    self.layer.addSublayer(lineLayer)
  }

}

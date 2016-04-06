//
//  EventDetailCollectionViewSectionHeader.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/3/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import DZNSegmentedControl

class EventDetailCollectionViewSectionHeader: UICollectionReusableView {
  
  @IBOutlet weak var controlView: UIView!
  
  var control: DZNSegmentedControl?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    let menuItems = ["Pending", "Accepted", "Declined"]
    control = DZNSegmentedControl(items: menuItems)
    control?.selectedSegmentIndex = 0
    //control?.height = 44
    control?.bouncySelectionIndicator = false
    control?.showsCount = false
    
    controlView = self.control
    
    
    // add a line to the bottom of the section header
    let lineLayer = CALayer()
    lineLayer.frame = CGRectMake(0, self.bounds.height - 1, self.bounds.width, 0.5)
    lineLayer.backgroundColor = UIColor.lightGrayColor().CGColor
    self.layer.addSublayer(lineLayer)
    
  }
  
}

extension EventDetailCollectionViewSectionHeader: DZNSegmentedControlDelegate {
  
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return UIBarPosition.Any
  }

  
}

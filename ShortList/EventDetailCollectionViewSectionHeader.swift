//
//  EventDetailCollectionViewSectionHeader.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/3/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class EventDetailCollectionViewSectionHeader: UICollectionReusableView {
  
  @IBOutlet weak var controlView: UIView!
  @IBOutlet weak var inviteButton: DesignableButton!
  @IBOutlet weak var sectionTitleLabel: UILabel!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // add a line to the bottom of the section header view
    let lineLayer = CALayer()
    lineLayer.frame = CGRectMake(0, self.bounds.height - 1, self.bounds.width, 0.5)
    lineLayer.backgroundColor = UIColor.lightGrayColor().CGColor
    self.layer.addSublayer(lineLayer)
  }
  
  // toggle header view depending on if the user owns this event
  func toggleIsOwner(isOwner: Bool) {
    if isOwner {
      inviteButton.hidden = false
      sectionTitleLabel.hidden = true
    }
    else {
      inviteButton.hidden = true
      sectionTitleLabel.hidden = false
    }
  }
  
}


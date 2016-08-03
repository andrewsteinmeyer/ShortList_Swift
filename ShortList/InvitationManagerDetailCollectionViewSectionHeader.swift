//
//  InvitationManagerDetailCollectionViewSectionHeader.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 8/1/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

class InvitationManagerCollectionViewSectionHeader: UICollectionReusableView {
  
  var event: Event?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    populateEventStats()
  }
  
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
      //inviteButton.hidden = false
      //sectionTitleLabel.hidden = true
    }
    else {
      //inviteButton.hidden = true
      //sectionTitleLabel.hidden = false
    }
  }
  
  func populateEventStats() {
    
  }
  
}


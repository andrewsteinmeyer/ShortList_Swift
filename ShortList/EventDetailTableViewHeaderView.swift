//
//  EventDetailTableViewHeaderView.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/6/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class EventDetailTableViewHeaderView: UIView {
  
  var ticketImageView: UIImageView? {
   didSet {
     guard let ticketImageView = ticketImageView else { return }
    
     ticketImageView.translatesAutoresizingMaskIntoConstraints = false
     self.addSubview(ticketImageView)
     
     let topConstraint = NSLayoutConstraint(item: ticketImageView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
     
     let bottomConstraint = NSLayoutConstraint(item: ticketImageView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
     
     let leftConstraint = NSLayoutConstraint(item: ticketImageView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
     
     let rightConstraint = NSLayoutConstraint(item: ticketImageView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
     
     self.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
    }
  }

}

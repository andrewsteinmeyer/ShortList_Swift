//
//  EventDetailCollectionViewHeaderView.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/31/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//


import UIKit

class EventDetailCollectionViewHeaderView: UICollectionReusableView {
  
  var ticketView: UIView? {
    didSet {
      guard let ticketView = ticketView else { return }
      
      ticketView.translatesAutoresizingMaskIntoConstraints = false
      self.addSubview(ticketView)
      
      let topConstraint = NSLayoutConstraint(item: ticketView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
      
      let bottomConstraint = NSLayoutConstraint(item: ticketView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
      
      let leftConstraint = NSLayoutConstraint(item: ticketView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
      
      let rightConstraint = NSLayoutConstraint(item: ticketView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
      
      self.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
    }
  }
  
  
}
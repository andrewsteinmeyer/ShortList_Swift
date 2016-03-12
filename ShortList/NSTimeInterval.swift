//
//  NSTimeInterval.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/12/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import Foundation

extension NSTimeInterval {
  
  // format epoch time to create NSDate
  func formatForNSDate() -> NSTimeInterval {
    return (self / 1000.0)
  }
  
}
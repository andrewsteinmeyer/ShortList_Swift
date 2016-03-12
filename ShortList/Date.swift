//
//  Date.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/8/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import Foundation

extension NSDate {
  
  // get time in milliseconds
  func timeInMilliseconds() -> NSTimeInterval {
    return self.timeIntervalSince1970 * 1000
  }
  
  // get epoch time from date
  func convertToEpoch() -> NSTimeInterval {
    return Double(floor(self.timeIntervalSince1970 / 100.0) * 100.0) * 1000.0
    
  }
  
}


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
  func timeInMilliseconds() -> Double {
    return self.timeIntervalSince1970 * 1000
  }
  
}


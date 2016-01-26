//
//  NSData.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/24/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import Foundation

extension NSData {
  func hexString() -> String {
    // "Array" of all bytes:
    let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(self.bytes), count:self.length)
    // Array of hex strings, one for each byte:
    let hexBytes = bytes.map { String(format: "%02hhx", $0) }
    // Concatenate all hex strings:
    return (hexBytes.joinWithSeparator(""))
  }
}

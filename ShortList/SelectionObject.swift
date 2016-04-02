//
//  SelectionObject.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/28/16
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class SelectionObject: NSObject {
  
  var originalCellPosition: CGRect
  var snapshot: UIView
  var selectedCellIndexPath: NSIndexPath
  
  var hidden =  false
  
  init(snapshot: UIView, selectedCellIndexPath: NSIndexPath, originalCellPosition: CGRect) {
    self.snapshot = snapshot
    self.selectedCellIndexPath = selectedCellIndexPath
    self.originalCellPosition = originalCellPosition
    
  }
}

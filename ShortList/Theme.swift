//
//  Theme.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 2/2/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import ChameleonFramework

enum Theme {
  case NavigationBarTintColor
  case NavigationBarBackgroundColor
  
  case MenuTableViewCellBackgroundColor
  case MenuTableViewCellBackgroundSelectedColor
  
  case MenuTableViewCellTextColor
  case MenuTableViewCellTextSelectedColor
  
  case MenuTableViewIconColor
  case MenuTableViewIconSelectedColor
  
  case ContactsTableViewCellSelectedColor
  
  func toUIColor() -> UIColor {
    switch self {
    case .NavigationBarTintColor:                    return HexColor("333333")
    case .NavigationBarBackgroundColor:              return HexColor("FFB700")
      
    case .MenuTableViewCellBackgroundColor:          return HexColor("555555")
    case .MenuTableViewCellBackgroundSelectedColor:  return HexColor("F5D76E")
      
    case .MenuTableViewCellTextColor:                return HexColor("FFFFFF")
    case .MenuTableViewCellTextSelectedColor:        return ContrastColorOf(Theme.MenuTableViewCellBackgroundSelectedColor.toUIColor(), returnFlat: true)
      
    case .MenuTableViewIconColor:                    return HexColor("FFB700")
    case .MenuTableViewIconSelectedColor:            return ContrastColorOf(Theme.MenuTableViewCellBackgroundSelectedColor.toUIColor(), returnFlat: true)
      
    case .ContactsTableViewCellSelectedColor:        return HexColor("FFC940")
    }
  }
}
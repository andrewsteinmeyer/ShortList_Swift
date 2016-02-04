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
  
  private struct Palette {
    static let headerBackgroundColor      = "F5D76E"
    //static let headerBackgroundColor      = "FFD673"
    static let headerTextColor            = "333333"
    
    static let menuBackgroundColor        = "303E4D"
    static let menuTextColor              = "FFECDB"
    static let menuIconColor              = "F5D76E"
    //static let menuIconColor              = "FCE353"  //brighter yellow
    
    static let tableCellSelectedColor     = "4C9689"
    static let tableCellTextSelectedColor = "FFECDB"
  }
  
  // Navigation
  case NavigationBarTintColor
  case NavigationBarBackgroundColor
  
  // TabBar
  case TabBarButtonTintColor
  
  // Menu
  case MenuHeaderViewBackgroundColor
  case MenuHeaderViewTextColor
  case MenuTableViewCellBackgroundColor
  case MenuTableViewCellBackgroundSelectedColor
  case MenuTableViewCellTextColor
  case MenuTableViewCellTextSelectedColor
  case MenuTableViewIconColor
  case MenuTableViewIconSelectedColor
  
  // List
  case ContactsTableViewCellBackgroundSelectedColor
  case ContactsTableViewCellTextColor
  case ContactsTableViewCellTextSelectedColor
  case ContactsTableViewCellSeparatorColor
  case ContactsTableViewCellSeparatorSelectedColor
  case SelectContactsHeaderViewBackgroundColor
  case SelectContactsHeaderViewTextColor
  
  func toUIColor() -> UIColor {
    switch self {
    case .NavigationBarTintColor:                        return HexColor(Palette.headerTextColor)
    case .NavigationBarBackgroundColor:                  return HexColor(Palette.headerBackgroundColor)
    
    case .TabBarButtonTintColor:                         return HexColor(Palette.headerTextColor)
      
    case .MenuHeaderViewBackgroundColor:                 return HexColor(Palette.menuBackgroundColor)
    case .MenuHeaderViewTextColor:                       return HexColor(Palette.menuTextColor)
    case .MenuTableViewCellBackgroundColor:              return HexColor(Palette.menuBackgroundColor)
    case .MenuTableViewCellBackgroundSelectedColor:      return HexColor(Palette.headerBackgroundColor)
    case .MenuTableViewCellTextColor:                    return HexColor(Palette.menuTextColor)
    case .MenuTableViewCellTextSelectedColor:            return ContrastColorOf(Theme.MenuTableViewCellBackgroundSelectedColor.toUIColor(), returnFlat: true)
    case .MenuTableViewIconColor:                        return HexColor(Palette.menuIconColor)
    case .MenuTableViewIconSelectedColor:                return ContrastColorOf(Theme.MenuTableViewCellBackgroundSelectedColor.toUIColor(), returnFlat: true)
      
    case .ContactsTableViewCellBackgroundSelectedColor:  return HexColor(Palette.tableCellSelectedColor)
    case .ContactsTableViewCellTextColor:                return HexColor(Palette.headerTextColor)
    case .ContactsTableViewCellTextSelectedColor:        return HexColor(Palette.tableCellTextSelectedColor)
    case .ContactsTableViewCellSeparatorColor:           return UIColor.lightGrayColor()
    case .ContactsTableViewCellSeparatorSelectedColor:   return HexColor(Palette.tableCellTextSelectedColor)
    case .SelectContactsHeaderViewBackgroundColor:       return HexColor(Palette.headerBackgroundColor)
    case .SelectContactsHeaderViewTextColor:             return HexColor(Palette.headerTextColor)
    }
  }
}
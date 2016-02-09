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
    
    //static let mainThemeColor             = "F5D76E"
    static let mainThemeColor             = "FFD673"
    static let mainThemeBackgroundColor   = "303E4D"
    static let mainThemeTextColor         = "333333"
    static let mainThemeErrorColor        = "EB4D5C"
    
    static let menuTextColor              = "FFECDB"
    //static let menuIconColor            = "FCE353"  //brighter yellow
    
    static let tableCellSelectedColor     = "4C9689"
    static let tableCellTextSelectedColor = "FFECDB"
  }
  
  // Sign In
  case SignInViewBackgroundColor
  case SignInViewThemeColor
  case SignInViewErrorColor
  
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
  
  // Contact
  case CreateContactButtonBackgroundColor
  case CreateContactButtonTextColor
  case CreateContactViewErrorColor
  
  // List
  case ContactsTableViewCellBackgroundSelectedColor
  case ContactsTableViewCellTextColor
  case ContactsTableViewCellTextSelectedColor
  case ContactsTableViewCellSeparatorColor
  case ContactsTableViewCellSeparatorSelectedColor
  case SelectContactsHeaderViewBackgroundColor
  case SelectContactsHeaderViewTextColor
  
  // Venue
  case CreateVenueButtonBackgroundColor
  case CreateVenueButtonTextColor
  case CreateVenueViewErrorColor
  
  // Event
  case CreateEventViewErrorColor
  
  func toUIColor() -> UIColor {
    switch self {
    
    // Sign In
    case .SignInViewBackgroundColor:                     return HexColor(Palette.mainThemeBackgroundColor)
    case .SignInViewThemeColor:                          return HexColor(Palette.mainThemeColor)
    case .SignInViewErrorColor:                          return HexColor(Palette.mainThemeErrorColor)
      
    // Navigation
    case .NavigationBarTintColor:                        return HexColor(Palette.mainThemeTextColor)
    case .NavigationBarBackgroundColor:                  return HexColor(Palette.mainThemeColor)
    
    // TabBar
    case .TabBarButtonTintColor:                         return HexColor(Palette.mainThemeTextColor)
      
    // Menu
    case .MenuHeaderViewBackgroundColor:                 return HexColor(Palette.mainThemeBackgroundColor)
    case .MenuHeaderViewTextColor:                       return HexColor(Palette.menuTextColor)
    case .MenuTableViewCellBackgroundColor:              return HexColor(Palette.mainThemeBackgroundColor)
    case .MenuTableViewCellBackgroundSelectedColor:      return HexColor(Palette.mainThemeColor)
    case .MenuTableViewCellTextColor:                    return HexColor(Palette.menuTextColor)
    case .MenuTableViewCellTextSelectedColor:            return ContrastColorOf(Theme.MenuTableViewCellBackgroundSelectedColor.toUIColor(), returnFlat: true)
    case .MenuTableViewIconColor:                        return HexColor(Palette.mainThemeColor)
    case .MenuTableViewIconSelectedColor:                return ContrastColorOf(Theme.MenuTableViewCellBackgroundSelectedColor.toUIColor(), returnFlat: true)
      
    // Contact
    case .CreateContactButtonBackgroundColor:            return HexColor(Palette.mainThemeColor)
    case .CreateContactButtonTextColor:                  return HexColor(Palette.mainThemeTextColor)
    case .CreateContactViewErrorColor:                   return HexColor(Palette.mainThemeErrorColor)
    
    // List
    case .ContactsTableViewCellBackgroundSelectedColor:  return HexColor(Palette.tableCellSelectedColor)
    case .ContactsTableViewCellTextColor:                return HexColor(Palette.mainThemeTextColor)
    case .ContactsTableViewCellTextSelectedColor:        return HexColor(Palette.tableCellTextSelectedColor)
    case .ContactsTableViewCellSeparatorColor:           return UIColor.lightGrayColor()
    case .ContactsTableViewCellSeparatorSelectedColor:   return HexColor(Palette.tableCellTextSelectedColor)
    case .SelectContactsHeaderViewBackgroundColor:       return HexColor(Palette.mainThemeColor)
    case .SelectContactsHeaderViewTextColor:             return HexColor(Palette.mainThemeTextColor)
      
    // Venue
    case .CreateVenueButtonBackgroundColor:              return HexColor(Palette.mainThemeColor)
    case .CreateVenueButtonTextColor:                    return HexColor(Palette.mainThemeTextColor)
    case .CreateVenueViewErrorColor:                     return HexColor(Palette.mainThemeErrorColor)
      
    // Event
    case .CreateEventViewErrorColor:                     return HexColor(Palette.mainThemeErrorColor)
    
    }
  }
}
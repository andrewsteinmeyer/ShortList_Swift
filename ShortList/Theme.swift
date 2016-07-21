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
    
    //static let mainThemeColor               = "F5D76E"
    //static let mainThemeColor               = "FFD673"
    //static let mainThemeErrorColor          = "DE495B"
    //static let mainThemeErrorColor          = "EB4D5C"
    //static let mainThemeButtonTextColor     = "428BCA"
    //static let scannerOutlineColor          = "65A0D6"
    
    static let mainThemeColor               = "639DD4" //light blue
    static let mainThemeTextColor           = "333333" //dark gray
    static let mainThemeErrorColor          = "D46365" //light red/pink
    static let mainThemeButtonTextColor     = "333333"
    static let mainThemeButtonColor         = "FFD673" //yellow
    
    static let secondaryHeaderColor         = "FFD673"
    
    static let segmentBackgroundColor       = "EDEDED"
    
    static let navBarActionButtonColor      = "FFFFFF"
    static let navBarTintColor              = "FFFFFF"
    
    static let tableCellBackgroundColor     = "FFFFFF"
    static let tableCellSelectedColor       = "4C9689"
    static let tableCellTextSelectedColor   = "FFECDB"
    static let tableCellSeparatorColor      = "AAAAAA"
    
    static let emptyDataSetTitleColor       = "C9C9C9"
    static let emptyDataSetDescriptionColor = "C9C9C9"
    
    static let eventInviteIconColor         = "4C9689"
    static let eventMessageIconColor        = "428BCA"
    static let eventAlertIconColor          = "EB4D5C"
    
    static let scannerOutlineColor          = "FFD673"
  }
  
  // Base Table View Cell
  case BaseTableViewCellTextColor
  case BaseTableViewCellBackgroundColor
  case BaseTableViewCellSeparatorColor
  
  // Empty Data Set
  case EmptyDataSetTitleColor
  case EmptyDataSetDescriptionColor
  
  // Sign In
  case SignInViewBackgroundColor
  case SignInViewThemeColor
  case SignInViewErrorColor
  case SignInViewTextFieldPlaceholderColor
  
  // Navigation
  case NavigationBarTintColor
  case NavigationBarBackgroundColor
  case NavigationBarActionButtonTextColor
  
  // TabBar
  case TabBarButtonTintColor
  
  // Contact
  case CreateContactButtonBackgroundColor
  case CreateContactButtonTextColor
  case CreateContactViewErrorColor
  
  // List
  case ContactsTableViewCellBackgroundSelectedColor
  case ContactsTableViewCellTextColor
  case ContactsTableViewCellTextSelectedColor
  case ContactsTableViewCellSeparatorSelectedColor
  case SelectContactsHeaderViewBackgroundColor
  case SelectContactsHeaderViewTextColor
  case DZNSegmentBackgroundColor
  
  // Venue
  case CreateVenueButtonBackgroundColor
  case CreateVenueButtonTextColor
  case CreateVenueViewErrorColor
  
  // Event
  case CreateEventViewErrorColor
  case EventDetailCancelButtonColor
  
  // Invitation
  case InvitationProgressButtonColor
  
  // Profile
  case ProfileTableViewHeaderTextColor
  case ProfileLogoutButtonTextColor
  
  // Alert
  case AlertEventInviteIconColor
  case AlertNewMessageIconColor
  case AlertDefaultIconColor
  
  // Scan
  case QRScannerOutlineColor
  case CancelScanButtonTextColor
  
  func toUIColor() -> UIColor {
    switch self {
      
    // Base Table View Cell
    case .BaseTableViewCellTextColor:                    return HexColor(Palette.mainThemeTextColor)
    case .BaseTableViewCellBackgroundColor:              return HexColor(Palette.tableCellBackgroundColor)
    case .BaseTableViewCellSeparatorColor:               return HexColor(Palette.tableCellSeparatorColor)
      
    // Empty Data Set
    case .EmptyDataSetTitleColor:                        return HexColor(Palette.emptyDataSetTitleColor)
    case .EmptyDataSetDescriptionColor:                  return HexColor(Palette.emptyDataSetDescriptionColor)
    
    // Sign In
    case .SignInViewBackgroundColor:                     return HexColor(Palette.mainThemeColor)
    case .SignInViewThemeColor:                          return HexColor(Palette.mainThemeButtonColor)
    case .SignInViewErrorColor:                          return HexColor(Palette.mainThemeErrorColor)
    case .SignInViewTextFieldPlaceholderColor:           return HexColor(Palette.mainThemeTextColor)
      
    // Navigation
    case .NavigationBarTintColor:                        return HexColor(Palette.navBarTintColor)
    case .NavigationBarBackgroundColor:                  return HexColor(Palette.mainThemeColor)
    case .NavigationBarActionButtonTextColor:            return HexColor(Palette.navBarActionButtonColor)
    
    // TabBar
    case .TabBarButtonTintColor:                         return HexColor(Palette.mainThemeColor)
      
    // Contact
    case .CreateContactButtonBackgroundColor:            return HexColor(Palette.mainThemeColor)
    case .CreateContactButtonTextColor:                  return HexColor(Palette.mainThemeTextColor)
    case .CreateContactViewErrorColor:                   return HexColor(Palette.mainThemeErrorColor)
    
    // List
    case .ContactsTableViewCellBackgroundSelectedColor:  return HexColor(Palette.tableCellSelectedColor)
    case .ContactsTableViewCellTextColor:                return HexColor(Palette.mainThemeTextColor)
    case .ContactsTableViewCellTextSelectedColor:        return HexColor(Palette.tableCellTextSelectedColor)
    case .ContactsTableViewCellSeparatorSelectedColor:   return HexColor(Palette.tableCellTextSelectedColor)
    case .SelectContactsHeaderViewBackgroundColor:       return HexColor(Palette.secondaryHeaderColor)
    case .SelectContactsHeaderViewTextColor:             return HexColor(Palette.mainThemeTextColor)
    case .DZNSegmentBackgroundColor:                     return HexColor(Palette.segmentBackgroundColor)
      
    // Venue
    case .CreateVenueButtonBackgroundColor:              return HexColor(Palette.mainThemeColor)
    case .CreateVenueButtonTextColor:                    return HexColor(Palette.mainThemeTextColor)
    case .CreateVenueViewErrorColor:                     return HexColor(Palette.mainThemeErrorColor)
      
    // Event
    case .CreateEventViewErrorColor:                     return HexColor(Palette.mainThemeErrorColor)
    case .EventDetailCancelButtonColor:                  return HexColor(Palette.mainThemeErrorColor)
    
    // Invitation
    case InvitationProgressButtonColor:                  return HexColor(Palette.mainThemeColor)
      
    // Profile
    case .ProfileTableViewHeaderTextColor:               return HexColor(Palette.mainThemeTextColor)
    case .ProfileLogoutButtonTextColor:                  return UIColor.whiteColor()
    
    // Alert
    case .AlertEventInviteIconColor:                     return HexColor(Palette.eventInviteIconColor)
    case .AlertNewMessageIconColor:                      return HexColor(Palette.eventMessageIconColor)
    case .AlertDefaultIconColor:                         return HexColor(Palette.eventAlertIconColor)
      
    // Scan
    case QRScannerOutlineColor:                          return HexColor(Palette.scannerOutlineColor)
    case CancelScanButtonTextColor:                      return HexColor(Palette.mainThemeTextColor)
    }
  }
}
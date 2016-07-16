//
//  Constants.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/21/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

struct Constants {
  
  // Meteor
  struct Meteor {
    private static let Domain = "slist.me"
    //private static let Domain = "app.myshortlists.com"
    //private static let Domain = "shortlist.meteor.com"
    //private static let Domain = "10.0.0.3:3000"
    //private static let Domain = "localhost:3000"

    static let RootUrl = "https://\(Domain)"
    //static let RootUrl = "http://\(Domain)"
    static let DDPUrl = "ws://\(Domain)/websocket"
  }
  
  // Google Maps
  struct GoogleMaps {
    static let ApiKey = "AIzaSyBk_737O6cJZiVdOlMhlaCWCyETfCcaQxc"
  }
  
  // Empty Data Set Messages
  struct EmptyDataSet {
    
    struct Title {
      static let FontName = "Lato"
      static let FontSize: CGFloat = 28.0
    }
    
    struct Description {
      static let FontName = "Lato"
      static let FontSize: CGFloat = 18.0
    }
    
    struct Home {
      static let Title = "Home Feed"
      static let Description = "There is no activity to display.\nGet started by adding some contacts."
    }
    
    struct List {
      static let Title = "No Lists"
      static let Description = "Create a list of contacts that you would like to invite to an event."
    }
    
    struct JoinedList {
      static let Title = "No Joined Lists"
      static let Description = "You have not joined any lists.\nJoin a list now and get in on the action."
    }
    
    struct Venue {
      static let Title = "No Venues"
      static let Description = "Add a venue that you would like to use as a location for an event."
    }
    
    struct Event {
      static let Title = "No Events"
      static let Description = "Create an event and invite people to join in on the fun."
    }
    
    struct Contact {
      static let Title = "No Contacts"
      static let Description = "Get started by adding some contacts."
    }
  }
  
  // Profile View Settings
  struct ProfileTableView {
    struct SectionHeaderView {
      static let Height: CGFloat = 50
      static let FontName = "Lato-Regular"
      static let FontSize: CGFloat = 14.0
    }
  }
  
  // Event Detail Collection Settings
  struct EventDetailCollection {
    static let CategoryCellIdentifier = "StatusCategoryCollectionViewCell"
    static let AttendeeCellIdentifier = "AttendeeCollectionViewCell"
    static let HeaderViewIdentifier = "EventDetailCollectionViewHeaderView"
    static let SectionHeaderIdentifier = "EventDetailCollectionViewSectionHeader"
    static let HeaderViewHeight: CGFloat = 256
  }
  
  // Guest List TableView Settings
  struct GuestListTableView {
    static let InviteeCellIdentifier = "InviteeTableViewCell"
    static let AttendeeCellIdentifier = "AttendeeTableViewCell"
    static let DeclinedCellIdentifier = "DeclinedTableViewCell"
    static let TimeoutCellIdentifier = "TimeoutTableViewCell"
  }
  
  // Menu Action Notifications
  struct MenuNotification {
    static let ProfileRowPressed = "shortlist.menu.profile.notification"
    static let VenuesRowPressed = "shortlist.menu.venue.notification"
  }
  
}
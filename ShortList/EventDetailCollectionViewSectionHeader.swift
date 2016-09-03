//
//  EventDetailCollectionViewSectionHeader.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/3/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import MapKit

private let dateFormatter: NSDateFormatter = {
  let formatter = NSDateFormatter()
  formatter.dateFormat = "EEE, MMM d" // ie. Thu, Jun 8
  
  return formatter
}()

private let timeFormatter: NSDateFormatter = {
  let formatter = NSDateFormatter()
  formatter.dateStyle = .NoStyle
  formatter.timeStyle = .ShortStyle // ie. 11:10 PM
  
  return formatter
}()

class EventDetailCollectionViewSectionHeader: UICollectionReusableView {
  typealias NamedValues = [String:AnyObject]
  
  @IBOutlet weak var shortlistNameLabel: UILabel!
  @IBOutlet weak var eventDateLabel: UILabel!
  @IBOutlet weak var eventTitleLabel: UILabel!
  @IBOutlet weak var eventDetailsTextView: UITextView!
  @IBOutlet weak var eventMapView: MKMapView!
  @IBOutlet weak var eventVenueLabel: UILabel!
  @IBOutlet weak var eventLocationAddressLabel: UILabel!
  @IBOutlet weak var locationStackView: UIStackView!
  
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // increase font of details text view
    eventDetailsTextView.font = UIFont(name: "Lato", size: 16)
    
    // add a line to the bottom of the section header view
    let lineLayer = CALayer()
    lineLayer.frame = CGRectMake(0, self.bounds.height - 1, self.bounds.width, 0.5)
    lineLayer.backgroundColor = UIColor.lightGrayColor().CGColor
    self.layer.addSublayer(lineLayer)
  }
  
  // toggle header view depending on if the user owns this event
  func toggleIsOwner(isOwner: Bool) {
    if isOwner {
      //inviteButton.hidden = false
      //sectionTitleLabel.hidden = true
    }
    else {
      //inviteButton.hidden = true
      //sectionTitleLabel.hidden = false
    }
  }
  
  func setEventData(event: Event?) {
    guard let event = event else { return }
    
    // set date
    if let epochDate = event.valueForKey("date") as? NSTimeInterval {
      let date = NSDate(timeIntervalSince1970: epochDate.formatForNSDate())
      
      let eventDate = dateFormatter.stringFromDate(date) as String
      let eventTime = timeFormatter.stringFromDate(date) as String
      
      self.eventDateLabel.text = "\(eventDate), \(eventTime)".uppercaseString
    }
    else {
      self.eventDateLabel.text = "NO DATE PROVIDED"
    }
    
    // set list name
    if let list = event.valueForKey("list") as? NamedValues {
      let JSONList = JSON(list)
      
      if let listName = JSONList["name"].string {
        shortlistNameLabel.text = listName
      }
    }
    else {
      self.shortlistNameLabel.text = "NO LIST NAME"
    }
    
    // set name and description
    self.eventTitleLabel.text = event.name ?? "NO TITLE PROVIDED"
    
    if let description = event.valueForKey("longDescription") as? String {
      self.eventDetailsTextView.text = description.uppercaseString
    }
    else {
      self.eventDetailsTextView.text = "No details were given for this event."
    }
    
    // set location name
    if let venue = event.valueForKey("venue") as? NamedValues {
      let JSONVenue = JSON(venue)
      
      // default to venue info
      var venueName = JSONVenue["name"].string ?? "No venue provided."
      var venueAddress = JSONVenue["location"]["address"].string ?? "No address provided."
      
      // if user has set location, override name and address
      if let locationName = JSONVenue["location"]["name"].string {
        venueName = locationName
      }
      if let locationAddress = JSONVenue["location"]["address"].string {
        venueAddress = locationAddress
      }
      
      self.eventVenueLabel.text = venueName
      self.eventLocationAddressLabel.text = venueAddress
      
      // populate map coordinates
      if let longitude = JSONVenue["location"]["longitude"].double,
        let latitude = JSONVenue["location"]["latitude"].double {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        self.eventMapView.setRegion(coordinateRegion, animated: false)
        
        // show location on map
        let locationPin = LocationMapPin(title: venueName, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        
        eventMapView.addAnnotation(locationPin)
      }
    }
  }
  
}


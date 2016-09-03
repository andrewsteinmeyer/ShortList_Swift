//
//  LocationMapPin.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 9/2/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import MapKit

class LocationMapPin: NSObject, MKAnnotation {
  let title: String?
  let coordinate: CLLocationCoordinate2D
  
  init(title: String, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.coordinate = coordinate
    
    super.init()
  }
  
}
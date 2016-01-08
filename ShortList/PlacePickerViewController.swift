//
//  PlacePickerViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/27/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import ObjectMapper

protocol PlacePickerViewControllerDelegate {
  func placePickerDidSelectLocation(location: Location)
}

class PlacePickerViewController: UIViewController {
  
  var locationManager: CLLocationManager!
  var placePicker: GMSPlacePicker!
  
  var delegate: PlacePickerViewControllerDelegate?
  
  var currentLocation: CLLocation? {
    didSet {
      let center = CLLocationCoordinate2DMake(currentLocation!.coordinate.latitude, currentLocation!.coordinate.longitude)
      let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
      let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
      let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
      let config = GMSPlacePickerConfig(viewport: viewport)
      self.placePicker = GMSPlacePicker(config: config)
      
      placePicker.pickPlaceWithCallback { (place: GMSPlace?, error: NSError?) -> Void in
        
        if let error = error {
          print("Error occurred: \(error.localizedDescription)")
          self.navigationController?.popViewControllerAnimated(true)
          return
        }
        
        if let place = place {
          let location = Location()
          location.name = place.name
          location.address = place.formattedAddress
          location.latitude = place.coordinate.latitude
          location.longitude = place.coordinate.longitude
          
          self.delegate?.placePickerDidSelectLocation(location)
          self.navigationController?.popViewControllerAnimated(true)
          
          
        } else {
          print("No place was selected")
          self.navigationController?.popViewControllerAnimated(true)
        }
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // setup location manager
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
  }
  
}

extension PlacePickerViewController: CLLocationManagerDelegate {
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == .AuthorizedWhenInUse {
      locationManager.startUpdatingLocation()
    }
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      locationManager.stopUpdatingLocation()
      
      print("location: \(location)")
      currentLocation = location
    }
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("An error occurred while tracking location changes : \(error.description)")
  }
}

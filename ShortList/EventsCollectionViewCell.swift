//
//  EventsCollectionViewCell.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/22/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

struct EventsCollectionViewCellData {
  
  init(name: String?, locationName: String?, date: String?, time: String?, acceptedCount: String?) {
    self.name = name ?? ""
    self.locationName = locationName ?? ""
    self.date = date ?? ""
    self.time = time ?? ""
    self.acceptedCount = acceptedCount ?? ""
  }
  
  var name: String?
  var locationName: String?
  var date: String?
  var time: String?
  var acceptedCount: String?
}

class EventsCollectionViewCell : UICollectionViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  override func awakeFromNib() {
    //self.layer.cornerRadius = 5
  }
  
  func setData(data: Any?) {
    if let data = data as? EventsCollectionViewCellData {
      self.nameLabel.text = data.name
      self.addressLabel.text = data.locationName
      self.dateLabel.text = data.date
      self.timeLabel.text = data.time
    }
  }
  
}
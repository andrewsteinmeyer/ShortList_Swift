//
//  EventsTableViewCell.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/4/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

struct EventsTableViewCellData {
  
  init(name: String?, locationName: String?, date: String?, time: String?) {
    self.name = name ?? ""
    self.locationName = locationName ?? ""
    self.date = date ?? ""
    self.time = time ?? ""
  }
  
  var name: String?
  var locationName: String?
  var date: String?
  var time: String?
}

class EventsTableViewCell : BaseTableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // add a line to the bottom of the section header
    let lineLayer = CALayer()
    lineLayer.frame = CGRectMake(0, self.bounds.height - 1, self.bounds.width, 0.5)
    lineLayer.backgroundColor = UIColor.lightGrayColor().CGColor
    self.layer.addSublayer(lineLayer)
  }
  
  override func setData(data: Any?) {
    if let data = data as? EventsTableViewCellData {
      self.nameLabel.text = data.name
      self.addressLabel.text = data.locationName
      self.dateLabel.text = data.date
      self.timeLabel.text = data.time
    }
  }
  
}

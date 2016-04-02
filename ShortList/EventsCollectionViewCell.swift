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
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    contentView.alpha = 1.0
    nameLabel = nil
    addressLabel = nil
    dateLabel = nil
    timeLabel = nil
  }
  
  
  var hide: Bool = false {
    didSet {
      let alpha: CGFloat = hide ? 0.0 : 1.0
      contentView.alpha = alpha
      backgroundView?.alpha = alpha
    }
  }
  
  var snapshot: UIView {
    get {
      let snapshot = snapshotViewAfterScreenUpdates(false)
      let layer = snapshot.layer
      layer.masksToBounds = false
      layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
      layer.shadowRadius = 5.0
      layer.shadowOpacity = 0.4
      return snapshot
    }
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
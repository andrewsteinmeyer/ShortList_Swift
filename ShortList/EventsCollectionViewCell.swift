//
//  EventsCollectionViewCell.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/22/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

struct EventsCollectionViewCellData {
  
  init(name: String?, locationName: String?, date: String?, time: String?, listName: String?, eventDescription: String?, acceptedCount: String?, declinedCount: String?) {
    self.name = name ?? ""
    self.locationName = locationName ?? ""
    self.date = date ?? ""
    self.time = time ?? ""
    self.listName = listName ?? ""
    self.eventDescription = eventDescription ?? ""
    self.acceptedCount = acceptedCount ?? ""
    self.declinedCount = declinedCount ?? ""
  }
  
  var name: String?
  var locationName: String?
  var date: String?
  var time: String?
  var listName: String?
  var eventDescription: String?
  var acceptedCount: String?
  var declinedCount: String?
}


class EventsCollectionViewCell : UICollectionViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var acceptedCount: UILabel!
  @IBOutlet weak var declinedCount: UILabel!
  @IBOutlet weak var inviteButton: DesignableButton!
  @IBOutlet weak var listNameLabel: UILabel!
  
  @IBOutlet weak var statsStackView: UIStackView!
  @IBOutlet weak var ticketBodyStackView: UIStackView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // hide invite button for now
    inviteButton.hidden = true
    
    // remove textview padding
    descriptionTextView.textContainer.lineFragmentPadding = 0
    descriptionTextView.textContainerInset = UIEdgeInsetsZero
    
    layer.masksToBounds = false
    layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    layer.shadowRadius = 5.0
    layer.shadowOpacity = 0.4
    
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
      // hide stats area for snapshot
      statsStackView.hidden = true
      
      let snapshot = snapshotViewAfterScreenUpdates(true)
      let layer = snapshot.layer
      layer.masksToBounds = false
      layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
      layer.shadowRadius = 5.0
      layer.shadowOpacity = 0.4
      
      // reveal stats area after we have snapshot
      statsStackView.hidden = false
      
      return snapshot
    }
  }
  
  func setData(data: Any?) {
    if let data = data as? EventsCollectionViewCellData {
      self.nameLabel.text = data.name
      self.addressLabel.text = data.locationName
      self.dateLabel.text = data.date
      self.timeLabel.text = data.time
      self.listNameLabel.text = data.listName
      self.acceptedCount.text = data.acceptedCount
      self.declinedCount.text = data.declinedCount
    }
  }
  
}
//
//  AlertsTableViewCell.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 2/28/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//


import UIKit
import TTTAttributedLabel

struct AlertsTableViewCellData {
  
  init(alertType: String?, title: String?, link: String?, insertedOn: String?) {
    self.alertType = alertType ?? ""
    self.title = title ?? ""
    self.link = link ?? ""
    self.insertedOn = insertedOn ?? ""
  }
  
  var alertType: String?
  var title: String?
  var link: String?
  var insertedOn: String?
}

class AlertsTableViewCell : BaseTableViewCell {
  
  @IBOutlet weak var alertIcon: UIImageView!
  @IBOutlet weak var alertTitle: TTTAttributedLabel!
  @IBOutlet weak var timeSinceAlert: UILabel!
  
  let lineLayer = CALayer()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // add a custom separator line to the bottom of the cell
    lineLayer.frame = CGRectMake(0, self.bounds.height - 1, self.bounds.width, 0.5)
    lineLayer.backgroundColor = Theme.BaseTableViewCellSeparatorColor.toUIColor().CGColor
    self.layer.addSublayer(lineLayer)
  }
  
  override func setData(data: Any?) {
    if let data = data as? AlertsTableViewCellData {
      self.alertTitle.text = data.title
      self.timeSinceAlert.text = data.insertedOn
      
      setIconImage(data.alertType)
    }
  }
  
  func setIconImage(alertType: String?) {
    guard let type = alertType else { return }
    
    switch type {
      case "eventInvite":
        self.alertIcon.image = UIImage(named: "calendar_2-outline")
        let alertImage = alertIcon.image?.imageWithColor(Theme.AlertEventInviteIconColor.toUIColor())
        alertIcon.image = alertImage
      case "newMessage":
        self.alertIcon.image = UIImage(named: "chats-outline")
        let messageImage = alertIcon.image?.imageWithColor(Theme.AlertNewMessageIconColor.toUIColor())
        alertIcon.image = messageImage
      default:
        self.alertIcon.image = UIImage(named: "alarm-outline")
        let defaultImage = alertIcon.image?.imageWithColor(Theme.AlertDefaultIconColor.toUIColor())
        alertIcon.image = defaultImage
    }
  }
  
}
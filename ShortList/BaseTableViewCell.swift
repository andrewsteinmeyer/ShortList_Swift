//
//  BaseTableViewCell.swift
//  Shortlist
//
//  Created by Andrew Steinmeyer on 12/15/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//
import UIKit

public class BaseTableViewCell : UITableViewCell {
  class var identifier: String { return String.className(self) }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  public override func awakeFromNib() {
  }
  
  public func setup() {
  }
  
  public class func height() -> CGFloat {
    return 44
  }
  
  public func setData(data: Any?) {
    self.backgroundColor = Theme.BaseTableViewCellBackgroundColor.toUIColor()
    self.textLabel?.textColor = Theme.BaseTableViewCellTextColor.toUIColor()
    if let menuText = data as? String {
      self.textLabel?.text = menuText
    }
  }
  
  override public func setHighlighted(highlighted: Bool, animated: Bool) {
    if highlighted {
      self.alpha = 0.4
    } else {
      self.alpha = 1.0
    }
  }
  
  // ignore the default handling
  override public func setSelected(selected: Bool, animated: Bool) {
  }
  
}

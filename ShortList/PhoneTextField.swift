//
//  PhoneTextField.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 2/23/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import PhoneNumberKit

@IBDesignable public class PhoneTextField: PhoneNumberTextField {
  
  @IBInspectable public var sidePadding: CGFloat = 0 {
    didSet {
      let padding = UIView(frame: CGRectMake(0, 0, sidePadding, sidePadding))
      
      leftViewMode = UITextFieldViewMode.Always
      leftView = padding
      
      rightViewMode = UITextFieldViewMode.Always
      rightView = padding
    }
  }
  
  @IBInspectable public var leftPadding: CGFloat = 0 {
    didSet {
      let padding = UIView(frame: CGRectMake(0, 0, leftPadding, 0))
      
      leftViewMode = UITextFieldViewMode.Always
      leftView = padding
    }
  }
  
  @IBInspectable public var rightPadding: CGFloat = 0 {
    didSet {
      let padding = UIView(frame: CGRectMake(0, 0, rightPadding, 0))
      
      rightViewMode = UITextFieldViewMode.Always
      rightView = padding
    }
  }
  
  @IBInspectable public var borderColor: UIColor = UIColor.clearColor() {
    didSet {
      layer.borderColor = borderColor.CGColor
    }
  }
  
  @IBInspectable public var borderWidth: CGFloat = 0 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  
  @IBInspectable public var cornerRadius: CGFloat = 0 {
    didSet {
      layer.cornerRadius = cornerRadius
    }
  }
  
  @IBInspectable public var lineHeight: CGFloat = 1.5 {
    didSet {
      let font = UIFont(name: self.font!.fontName, size: self.font!.pointSize)
      let text = self.text
      
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.lineSpacing = lineHeight
      
      let attributedString = NSMutableAttributedString(string: text!)
      attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
      attributedString.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, attributedString.length))
      
      self.attributedText = attributedString
    }
  }
  
}
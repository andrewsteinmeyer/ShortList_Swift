//
//  DataPicker.swift
//  iDoctors
//
//  Created by Valerio Ferrucci on 30/09/14.
//  Copyright (c) 2014 Tabasoft. All rights reserved.
//

import UIKit


public class PopDatePicker : NSObject, UIPopoverPresentationControllerDelegate, DatePickerViewControllerDelegate {
    
    public typealias PopDatePickerCallback = (newDate : NSDate, forButton : UIButton)->()
    
    var datePickerVC : PopDateViewController
    var popover : UIPopoverPresentationController?
    var button : UIButton!
    var dataChanged : PopDatePickerCallback?
    var presented = false
    var offset : CGFloat = 8.0
    
    public init(forButton: UIButton) {
        
        datePickerVC = PopDateViewController()
        self.button = forButton
        super.init()
    }
    
    public func pick(inViewController : UIViewController, initDate : NSDate?, dataChanged : PopDatePickerCallback) {
        
        if presented {
            return  // we are busy
        }
        
        datePickerVC.delegate = self
        datePickerVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        datePickerVC.preferredContentSize = CGSizeMake(500,208)
        datePickerVC.currentDate = initDate
        
        popover = datePickerVC.popoverPresentationController
        if let _popover = popover {
            _popover.sourceView = button
            _popover.sourceRect = CGRectMake(self.offset,button.bounds.size.height,0,0)
            _popover.permittedArrowDirections = .Up
            _popover.delegate = self
            self.dataChanged = dataChanged
            inViewController.presentViewController(datePickerVC, animated: true, completion: nil)
            presented = true
        }
    }
    
    public func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func datePickerVCDismissed(date : NSDate?) {
        if let _dataChanged = dataChanged {
            if let _date = date {
                _dataChanged(newDate: _date, forButton: button)
            }
        }
        presented = false
    }
}

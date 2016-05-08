//
//  Invitation.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/24/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import CoreData

class Invitation: NSManagedObject {
  typealias NamedValues = [String:AnyObject]
  
  @NSManaged var userId: String?
  @NSManaged var eventId: String?
  @NSManaged var listId: String?
  @NSManaged var contact: NamedValues?
  @NSManaged var duration: NSNumber?
  @NSManaged var insertedOn: NSTimeInterval
  @NSManaged var status: String?
  @NSManaged var actionUpdated: NSTimeInterval
  
  dynamic private (set) var readableTimeRemaining: String?
  private (set) var timer: NSTimer?
  
  lazy var readableInvitedDate: NSDate = {
    [unowned self] in
    
    return NSDate(timeIntervalSince1970: self.insertedOn)
  }()
  
  lazy var expiryTime: NSTimeInterval = {
    [unowned self] in
    
    let secondsUntilExpiration = self.duration ?? 3600
    return (self.insertedOn + Double(secondsUntilExpiration))
  }()
  
  var timeRemaining: Int {
    return Int(expiryTime - NSDate().timeIntervalSince1970)
  }
  
  deinit {
    // stop timer and clean up
    stopCountdown()
  }
  
  /*!
   * The invitation keeps a local record of the countdown
   * The client checks the countdown every second
   */
  func startCountdown() {
    updateCountdown()
    
    // return if time has expired
    guard timeRemaining > 0 else { return }
    
    // start timer that will check every second
    timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(Invitation.updateCountdown), userInfo: nil, repeats: true)
    
    // use NSRunLoopCommonModes so timer continues to countdown when user interacts with screen
    NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
  }
  
  /*!
   * Called to update the countdown timer
   */
  func updateCountdown() {
    let secondsRemaining = timeRemaining
    
    // still time on the clock
    if secondsRemaining > 0 {
      let (m,s) = secondsToMinutesSeconds(secondsRemaining)
      
      switch m {
      case _ where m > 1:
        readableTimeRemaining = (s < 10) ? "\(m):0\(s)" : "\(m):\(s)"
      case _ where m < 1:
        readableTimeRemaining = (s < 10) ? "00:0\(s)" : "00:\(s)"
      default:
        break
      }
    // time is up, stop timer
    } else {
      readableTimeRemaining = "00:00"
      
      if let timer = timer {
        timer.invalidate()
      }
    }
  }
  
  func stopCountdown() {
    if let timer = timer {
      timer.invalidate()
    }
  }
  
}



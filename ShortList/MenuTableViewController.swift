//
//  MenuTableViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/31/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import ChameleonFramework

class MenuTableViewController: UITableViewController {
  
  private enum Menu: Int {
    case Venues = 0
    case Contacts
    case Notifications
    case Profile
  }
  
  // Header
  @IBOutlet weak var headerView: UIView!
  
  // Venues
  @IBOutlet weak var venuesTableViewCell: UITableViewCell!
  @IBOutlet weak var venuesTitleLabel: UILabel!
  @IBOutlet weak var venuesIconImageView: UIImageView!
  
  // Contacts
  @IBOutlet weak var contactsTableViewCell: UITableViewCell!
  @IBOutlet weak var contactsTitleLabel: UILabel!
  @IBOutlet weak var contactsIconImageView: UIImageView!
  
  // Notifications
  @IBOutlet weak var notificationsTableViewCell: UITableViewCell!
  @IBOutlet weak var notificationsTitleLabel: UILabel!
  @IBOutlet weak var notificationsIconImageView: UIImageView!
  
  // Profile
  @IBOutlet weak var profileTableViewCell: UITableViewCell!
  @IBOutlet weak var profileTitleLabel: UILabel!
  @IBOutlet weak var profileIconImageView: UIImageView!
  
  private var selectedRow: Menu = .Venues
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // setup Menu theme
    setupMenuAppearance()
  }
  
  //MARK: - Private methods
  
  private func setupMenuAppearance() {
    // set main background color
    view.backgroundColor = Theme.MenuTableViewCellBackgroundColor.toUIColor()
    
    // set colors on header
    setupHeaderAppearance()
    
    // set colors on menu rows
    setupMenuTableViewCells()
  }
  
  private func setupMenuTableViewCells() {
    setCellBackgroundColor()
    setSelectedCellColor()
    setInitialTextColor()
    setInitialIconColor()
    
    // trigger layoutSubviews() to refresh and set the new background views
    view.layoutSubviews()
  }
  
  private func setCellBackgroundColor() {
    let backgroundColor = Theme.MenuTableViewCellBackgroundColor.toUIColor()
  
    venuesTableViewCell.backgroundColor = backgroundColor
    contactsTableViewCell.backgroundColor = backgroundColor
    notificationsTableViewCell.backgroundColor = backgroundColor
    profileTableViewCell.backgroundColor = backgroundColor
  }
  
  private func setSelectedCellColor() {
    // create the selected color view
    let selectedColorView = UIView(frame: venuesTableViewCell.bounds)
    selectedColorView.backgroundColor = Theme.MenuTableViewCellBackgroundSelectedColor.toUIColor()
    
    // set the selected color view
    // this color appears when the user selects a row
    venuesTableViewCell.selectedBackgroundView = selectedColorView
    contactsTableViewCell.selectedBackgroundView = selectedColorView
    notificationsTableViewCell.selectedBackgroundView = selectedColorView
    profileTableViewCell.selectedBackgroundView = selectedColorView
  }
  
  private func setInitialTextColor() {
    let initialTextColor = Theme.MenuTableViewCellTextColor.toUIColor()
    venuesTitleLabel.textColor = initialTextColor
    contactsTitleLabel.textColor = initialTextColor
    notificationsTitleLabel.textColor = initialTextColor
    profileTitleLabel.textColor = initialTextColor
  }
  
  private func setInitialIconColor() {
    let initialIconColor = Theme.MenuTableViewIconColor.toUIColor()
    
    let venueImage = venuesIconImageView.image?.imageWithColor(initialIconColor)
    venuesIconImageView.image = venueImage
    
    let contactImage = contactsIconImageView.image?.imageWithColor(initialIconColor)
    contactsIconImageView.image = contactImage
    
    let notificationsImage = notificationsIconImageView.image?.imageWithColor(initialIconColor)
    notificationsIconImageView.image = notificationsImage
    
    let profileImage = profileIconImageView.image?.imageWithColor(initialIconColor)
    profileIconImageView.image = profileImage
  }
  
  private func setupHeaderAppearance() {
    headerView.backgroundColor = Theme.MenuHeaderViewBackgroundColor.toUIColor()
  }
  
  private func setSelectedRow(row: Menu = .Venues) {
    // if a previous row was selected,
    // then set its colors back to unselected
    let previousRow = selectedRow
    unhighlightRow(previousRow)
    
    // update the colors of the new selected row
    let currentRow = row
    highlightRow(currentRow)
  
    // store new selected row
    selectedRow = row
  }
  
  // highlighted row is the same color as the background for now
  // keeping this functionality in here in case that changes
  
  private func unhighlightRow(row: Menu) {
    let imageColor = Theme.MenuTableViewIconColor.toUIColor()
    let textColor = Theme.MenuTableViewCellTextColor.toUIColor()
    
    updateRow(row, imageColor: imageColor, textColor: textColor, selected: false)
  }
  
  private func highlightRow(row: Menu) {
    let imageColor = Theme.MenuTableViewIconSelectedColor.toUIColor()
    let textColor = Theme.MenuTableViewCellTextSelectedColor.toUIColor()
    
    updateRow(row, imageColor: imageColor, textColor: textColor, selected: true)
  }

  private func updateRow(menuRow: Menu, imageColor: UIColor, textColor: UIColor, selected: Bool) {
    // update corresponding row
    switch menuRow {
    case .Venues:
      let image = venuesIconImageView.image?.imageWithColor(imageColor)
      venuesIconImageView.image = image
      venuesTitleLabel.textColor = textColor
      venuesTableViewCell.selected = selected
    case .Contacts:
      let image = contactsIconImageView.image?.imageWithColor(imageColor)
      contactsIconImageView.image = image
      contactsTitleLabel.textColor = textColor
      contactsTableViewCell.selected = selected
    case .Notifications:
      let image = notificationsIconImageView.image?.imageWithColor(imageColor)
      notificationsIconImageView.image = image
      notificationsTitleLabel.textColor = textColor
      notificationsTableViewCell.selected = selected
    case .Profile:
      let image = profileIconImageView.image?.imageWithColor(imageColor)
      profileIconImageView.image = image
      profileTitleLabel.textColor = textColor
      profileTableViewCell.selected = selected
    }
    
  }
  
  //MARK: - Helper methods
  
  // highlighted row is the same color as the background for now
  // keeping this functionality in here in case that changes
  private func selectRow(row: Menu) {
    let previousRow = selectedRow
    unhighlightRow(previousRow)
    
    self.selectedRow = row
  }
  
  //MARK: - UITableViewDelegate
  
  override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // update selected row
    if let selectedRow = Menu(rawValue: indexPath.row) {
      setSelectedRow(selectedRow)
    }
    
    return true
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let selectedRow = Menu(rawValue: indexPath.row) {
      switch selectedRow {
      case .Venues:
        postVenuesRowPressedNotification()
      case .Profile:
        postProfileRowPressedNotification()
      default: ()
      }
    }
  }
  
  //MARK: - Notifications
  
  private func postProfileRowPressedNotification() {
    NSNotificationCenter.defaultCenter().postNotificationName(Constants.MenuNotification.ProfileRowPressed, object: nil)
  }
  
  private func postVenuesRowPressedNotification() {
    NSNotificationCenter.defaultCenter().postNotificationName(Constants.MenuNotification.VenuesRowPressed, object: nil)
  }
  

}

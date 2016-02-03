//
//  MenuTableViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/31/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import ChameleonFramework

enum Menu: Int {
  case Home = 0
  case Lists
  case Venues
  case Events
  case Contacts
}

class MenuTableViewController: UITableViewController {

  // Header
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var emailLabel: UILabel!
 
  // Home
  @IBOutlet weak var homeTableViewCell: UITableViewCell!
  @IBOutlet weak var homeTitleLabel: UILabel!
  @IBOutlet weak var homeIconImageView: UIImageView!
  
  // Lists
  @IBOutlet weak var listsTableViewCell: UITableViewCell!
  @IBOutlet weak var listsTitleLabel: UILabel!
  @IBOutlet weak var listsIconImageView: UIImageView!
  
  // Venues
  @IBOutlet weak var venuesTableViewCell: UITableViewCell!
  @IBOutlet weak var venuesTitleLabel: UILabel!
  @IBOutlet weak var venuesIconImageView: UIImageView!
  
  // Events
  @IBOutlet weak var eventsTableViewCell: UITableViewCell!
  @IBOutlet weak var eventsTitleLabel: UILabel!
  @IBOutlet weak var eventsIconImageView: UIImageView!
  
  // Contacts
  @IBOutlet weak var contactsTableViewCell: UITableViewCell!
  @IBOutlet weak var contactsTitleLabel: UILabel!
  @IBOutlet weak var contactsIconImageView: UIImageView!
  
  var selectedRow = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set user details
    if let user = AccountManager.defaultAccountManager.currentUser {
      emailLabel.text = user.emailAddress
      nameLabel.text = user.name
    }
    
    // setup highlight view for menu cells
    setupMenuTableViewCells()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // set the selected row before the view appears
    setSelectedRow()
  }
  
  //MARK: - Private methods
  
  private func setupMenuTableViewCells() {
    // create the selected color view
    let selectedColorView = UIView(frame: homeTableViewCell.bounds)
    selectedColorView.backgroundColor = Theme.MenuTableViewCellBackgroundSelectedColor.toUIColor()
    
    // set the selected color view
    // this color appears when the user selects a row
    homeTableViewCell.selectedBackgroundView = selectedColorView
    listsTableViewCell.selectedBackgroundView = selectedColorView
    venuesTableViewCell.selectedBackgroundView = selectedColorView
    eventsTableViewCell.selectedBackgroundView = selectedColorView
    contactsTableViewCell.selectedBackgroundView = selectedColorView
    
    // trigger layoutSubviews() to set the new background views to the correct size
    view.layoutSubviews()
  }
  
  private func setSelectedRow() {
    // highlight the selected row before the view appears
    if let menuRow = Menu(rawValue: selectedRow) {
      let imageColor = Theme.MenuTableViewIconSelectedColor.toUIColor()
      let textColor = Theme.MenuTableViewCellTextSelectedColor.toUIColor()
      
      updateRow(menuRow, imageColor: imageColor, textColor: textColor, selected: true)
    }
  }
  
  private func updateRow(menuRow: Menu, imageColor: UIColor, textColor: UIColor, selected: Bool) {
    // update corresponding row
    switch menuRow {
    case .Home:
      let image = homeIconImageView.image?.imageWithColor(imageColor)
      homeIconImageView.image = image
      homeTitleLabel.textColor = textColor
      homeTableViewCell.selected = selected
    case .Lists:
      let image = listsIconImageView.image?.imageWithColor(imageColor)
      listsIconImageView.image = image
      listsTitleLabel.textColor = textColor
      listsTableViewCell.selected = selected
    case .Venues:
      let image = venuesIconImageView.image?.imageWithColor(imageColor)
      venuesIconImageView.image = image
      venuesTitleLabel.textColor = textColor
      venuesTableViewCell.selected = selected
    case .Events:
      let image = eventsIconImageView.image?.imageWithColor(imageColor)
      eventsIconImageView.image = image
      eventsTitleLabel.textColor = textColor
      eventsTableViewCell.selected = selected
    case .Contacts:
      let image = contactsIconImageView.image?.imageWithColor(imageColor)
      contactsIconImageView.image = image
      contactsTitleLabel.textColor = textColor
      contactsTableViewCell.selected = selected
    }
  }
  
  //MARK: - UITableViewDelegate
  
  override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // if a previous row was selected,
    // then update its colors back to unselected
    let previousRow = selectedRow
    if let menuRow = Menu(rawValue: previousRow) {
      let imageColor = Theme.MenuTableViewIconColor.toUIColor()
      let textColor = Theme.MenuTableViewCellTextColor.toUIColor()
      
      updateRow(menuRow, imageColor: imageColor, textColor: textColor, selected: false)
    }
    
    // update the colors of the new selected row
    let currentRow = indexPath.row
    if let menuRow = Menu(rawValue: currentRow) {
      let imageColor = Theme.MenuTableViewIconSelectedColor.toUIColor()
      let textColor = Theme.MenuTableViewCellTextSelectedColor.toUIColor()
      
      updateRow(menuRow, imageColor: imageColor, textColor: textColor, selected: true)
      
      // store reference to the selected row
      selectedRow = indexPath.row
    }
    
    return true
  }
  

}

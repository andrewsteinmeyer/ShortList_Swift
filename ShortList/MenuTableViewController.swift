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
  case Spacer
  case Profile
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
  
  // Spacer
  @IBOutlet weak var spacerTableViewCell: UITableViewCell!
  
  // Profile
  @IBOutlet weak var profileTableViewCell: UITableViewCell!
  @IBOutlet weak var profileTitleLabel: UILabel!
  @IBOutlet weak var profileIconImageView: UIImageView!
  
  
  @IBAction func logOut(sender: AnyObject) {
    AccountManager.defaultAccountManager.signOut()
  }
  
  // initial selected row is .Home
  var selectedRow = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // setup Menu theme
    setupMenuAppearance()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // set user details
    // TODO: add event listener for when user has successfully logged in.
    //       update the emailAddress and name when notified of succesful log in.
    if let user = AccountManager.defaultAccountManager.currentUser {
      emailLabel.text = user.emailAddress
      nameLabel.text = user.name
    }
    
    // set the selected row before the view appears
    setSelectedRow()
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
    
    // trigger layoutSubviews() to set the new background views to the correct size
    view.layoutSubviews()
  }
  
  private func setCellBackgroundColor() {
    let backgroundColor = Theme.MenuTableViewCellBackgroundColor.toUIColor()
  
    homeTableViewCell.backgroundColor = backgroundColor
    listsTableViewCell.backgroundColor = backgroundColor
    venuesTableViewCell.backgroundColor = backgroundColor
    eventsTableViewCell.backgroundColor = backgroundColor
    contactsTableViewCell.backgroundColor = backgroundColor
    spacerTableViewCell.backgroundColor = backgroundColor
    profileTableViewCell.backgroundColor = backgroundColor
  }
  
  private func setSelectedCellColor() {
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
    profileTableViewCell.selectedBackgroundView = selectedColorView
  }
  
  private func setInitialTextColor() {
    let initialTextColor = Theme.MenuTableViewCellTextColor.toUIColor()
    homeTitleLabel.textColor = initialTextColor
    listsTitleLabel.textColor = initialTextColor
    venuesTitleLabel.textColor = initialTextColor
    eventsTitleLabel.textColor = initialTextColor
    contactsTitleLabel.textColor = initialTextColor
    profileTitleLabel.textColor = initialTextColor
  }
  
  private func setInitialIconColor() {
    let initialIconColor = Theme.MenuTableViewIconColor.toUIColor()
    
    let homeImage = homeIconImageView.image?.imageWithColor(initialIconColor)
    homeIconImageView.image = homeImage
    
    let listImage = listsIconImageView.image?.imageWithColor(initialIconColor)
    listsIconImageView.image = listImage
    
    let venueImage = venuesIconImageView.image?.imageWithColor(initialIconColor)
    venuesIconImageView.image = venueImage
    
    let eventImage = eventsIconImageView.image?.imageWithColor(initialIconColor)
    eventsIconImageView.image = eventImage
    
    let contactImage = contactsIconImageView.image?.imageWithColor(initialIconColor)
    contactsIconImageView.image = contactImage
    
    let profileImage = profileIconImageView.image?.imageWithColor(initialIconColor)
    profileIconImageView.image = profileImage
  }
  
  private func setupHeaderAppearance() {
    headerView.backgroundColor = Theme.MenuHeaderViewBackgroundColor.toUIColor()
    emailLabel.textColor = Theme.MenuHeaderViewTextColor.toUIColor()
    nameLabel.textColor = Theme.MenuHeaderViewTextColor.toUIColor()
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
    case .Spacer:
      break
    case .Profile:
      let image = profileIconImageView.image?.imageWithColor(imageColor)
      profileIconImageView.image = image
      profileTitleLabel.textColor = textColor
      profileTableViewCell.selected = selected
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

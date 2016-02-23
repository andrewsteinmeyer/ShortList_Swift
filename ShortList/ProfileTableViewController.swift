//
//  ProfileViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 2/16/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
  
  @IBOutlet weak var menuButton: UIBarButtonItem!
  @IBOutlet weak var firstNameLabel: UILabel!
  @IBOutlet weak var lastNameLabel: UILabel!
  @IBOutlet weak var emailAddressLabel: UILabel!
  @IBOutlet weak var phoneNumberLabel: UILabel!
  @IBOutlet weak var logoutButton: UIButton!

  
  let sectionHeaders = ["Name", "Profile"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if self.revealViewController() != nil {
      menuButton.target = self.revealViewController()
      menuButton.action = "revealToggle:"
      self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    setupAppearance()
    
    // retrieve profile details
    let user = AccountManager.defaultAccountManager.currentUser
    
    var profileImage = user?.image
    let firstName = user?.firstName
    let lastName = user?.lastName
    let emailAddress = user?.emailAddress
    var phoneNumber = ""
    
    if let number = user?.phone?.toNational() {
      phoneNumber = String(number)
    }
    
    // set profile picture
    profileImage = profileImage != nil ? profileImage : UIImage(named: "background_poly")
    let thumbnailImage = profileImage?.thumbnailImage(96, transparentBorder: 0, cornerRadius: 48, interpolationQuality: .Default)
    let imageView = UIImageView(image: thumbnailImage)
    
    // set user details
    firstNameLabel.text = firstName != nil ? firstName : ""
    lastNameLabel.text = lastName != nil ? lastName : ""
    emailAddressLabel.text = emailAddress != nil ? emailAddress : ""
    phoneNumberLabel.text = phoneNumber
    
    // add profile image to view
    view.addSubview(imageView)
    
    // must turn off auto contraints when using autolayout
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    let horizontalConstraints = NSLayoutConstraint(item: imageView, attribute: .LeadingMargin, relatedBy: .Equal, toItem: view,
      attribute: .LeadingMargin, multiplier: 1.0, constant: 7)
    
    let verticalConstraints = NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal,
      toItem: view, attribute: .Top, multiplier: 1.0, constant: 34)
    
    // activate the new constraints
    NSLayoutConstraint.activateConstraints([horizontalConstraints, verticalConstraints])
    
  }
  
  @IBAction func logoutButtonDidPress(sender: AnyObject) {
    AccountManager.defaultAccountManager.signOut()
  }
  
  func setupAppearance() {
    // set button color
    let buttonTextColor = Theme.ProfileLogoutButtonTextColor.toUIColor()

    logoutButton.setTitleColor(buttonTextColor, forState: .Normal)
  }
  
  //MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return Constants.ProfileTableView.SectionHeaderView.Height
  }
  
  override func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    return Constants.ProfileTableView.SectionHeaderView.Height
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    let section = indexPath.section
    if section == 0 {
      if (cell.respondsToSelector("setSeparatorInset:")) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 125, bottom: 0, right: 0)
      }
      
      if (cell.respondsToSelector("setLayoutMargins:")) {
        
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 125, bottom: 0, right: 0)
      }
    }
  }
  
  //MARK: UITableViewSource
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let height = Constants.ProfileTableView.SectionHeaderView.Height
    let fontName = Constants.ProfileTableView.SectionHeaderView.FontName
    let fontSize = Constants.ProfileTableView.SectionHeaderView.FontSize
    
    
    // create section header view
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: height))
    
    if section < 2 {
      let horizontalPadding: CGFloat = section == 0 ? 125 : 15
      let verticalPadding: CGFloat = height - fontSize - 5
    
      let titleLabel = UILabel(frame: CGRect(x: horizontalPadding, y: verticalPadding, width: tableView.frame.size.width - horizontalPadding, height: fontSize))
      titleLabel.textColor = Theme.ProfileTableViewHeaderTextColor.toUIColor()
      titleLabel.font = UIFont(name: fontName, size: fontSize)
      titleLabel.text = sectionHeaders[section]
    
      headerView.addSubview(titleLabel)
    }
    
    return headerView
  }
  
}
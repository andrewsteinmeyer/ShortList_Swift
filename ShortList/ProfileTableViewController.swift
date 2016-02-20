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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if self.revealViewController() != nil {
      menuButton.target = self.revealViewController()
      menuButton.action = "revealToggle:"
      self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    // setup profile image
    let profileImage = UIImage(named: "background_poly")
    let thumbnailImage = profileImage?.thumbnailImage(95, transparentBorder: 0, cornerRadius: 7, interpolationQuality: .Default)
    let imageView = UIImageView(image: thumbnailImage)
    
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
  
  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    if let headerView = view as? UITableViewHeaderFooterView {
      headerView.textLabel!.textColor = Theme.ProfileTableViewHeaderTextColor.toUIColor()
      headerView.textLabel!.font = UIFont(name: "Lato-Regular", size: 14)
    }
  }
  
}
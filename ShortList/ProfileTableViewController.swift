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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if self.revealViewController() != nil {
      menuButton.target = self.revealViewController()
      menuButton.action = "revealToggle:"
      self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    let profileImage = UIImage(named: "background_poly")
    let imageView = UIImageView(image: profileImage)
    imageView.layer.cornerRadius = 10
    
    view.addSubview(imageView)
    
  }
  
  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    if let headerView = view as? UITableViewHeaderFooterView {
      headerView.textLabel!.textColor = Theme.ProfileTableViewHeaderTextColor.toUIColor()
      headerView.textLabel!.font = UIFont(name: "Lato-Bold", size: 14)
    }
  }
  
}

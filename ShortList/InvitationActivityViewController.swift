//
//  InvitationActivityViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/20/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import WebKit

class InvitationActivityViewController: UIViewController {
  
  var url: String!
  var webView: WKWebView!
  
  override func loadView() {
    super.loadView()
    self.webView = WKWebView()
    self.view = self.webView
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.navigationBarHidden = true
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  

  override func viewDidLoad() {
    super.viewDidLoad()
    let targetURL = NSURL(string: url)
    let request = NSURLRequest(URL: targetURL!)
    webView.loadRequest(request)
  }
  
  
}

//
//  AlertLinkViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/4/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import WebKit

class AlertLinkViewController: UIViewController {
  
  var url: String!
  var webView: WKWebView!
  
  override func loadView() {
    super.loadView()
    self.webView = WKWebView()
    self.view = self.webView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    webView.navigationDelegate = self
    webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    
    let targetURL = NSURL(string: url)
    let request = NSURLRequest(URL: targetURL!)
    
    webView.loadRequest(request)
    
  }
  
  deinit {
    webView.removeObserver(self, forKeyPath: "estimatedProgress")
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if (keyPath == "estimatedProgress") {
      print("progress: \(webView.estimatedProgress)")
    }
  }
  
}

//MARK: WKWebView Delegate

extension AlertLinkViewController: WKNavigationDelegate {
  
  func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
    print("here in decide policy")
    if navigationResponse.response.isKindOfClass(NSHTTPURLResponse) {
      print("http response:")
      print(navigationResponse.response)
      
    }
    decisionHandler(.Allow)
  }
  
  func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
    print("navigation action")
    decisionHandler(.Allow)
  }
  
  func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
    print("did commit navigation")
  }
  
  func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
    print("did finish navigation")
  }
  
  func webViewWebContentProcessDidTerminate(webView: WKWebView) {
    print("did terminate content processing")
  }
  
  func webView(webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
    print("received server redirect")
  }
  
  func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    print("got here in provisioning")
  }
  
  func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
    print("error provisional load: \(error)")
  }
  
  func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
    print("error failed navigation: \(error)")
  }
  
  func webView(webView: WKWebView, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge,
    completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
      let cred = NSURLCredential.init(forTrust: challenge.protectionSpace.serverTrust!)
      print("credential: \(cred)")
      completionHandler(.UseCredential, cred)
  }

}
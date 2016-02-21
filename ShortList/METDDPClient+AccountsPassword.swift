//
//  METDDPClient+AccountsPassword.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 2/18/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import Meteor

extension METDDPClient {
  
  // sign up with name and email
  func signUpWithEmail(email: String, password: String, name: String, completionHandler: METLogInCompletionHandler) {
    let profile = ["name" : name]
    
    self.signUpWithEmail(email, password: password, profile: profile, completionHandler: completionHandler)
  }
  
  // sign up with name, email and phone number
  func signUpWithEmail(email: String, password: String, name: String, phone: String, completionHandler: METLogInCompletionHandler) {
    let profile: [NSObject: AnyObject] = ["name" : name,
                                          "phones": [
                                                      ["number": phone, "verified": false]
                                                    ]
                                         ]
    self.signUpWithEmail(email, password: password, profile: profile, completionHandler: completionHandler)
  }
  
}

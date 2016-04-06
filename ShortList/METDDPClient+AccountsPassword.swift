//
//  METDDPClient+AccountsPassword.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 2/18/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

extension METDDPClient {
  
  // sign up with name and email
  func signUpWithEmail(email: String, password: String, name: String, completionHandler: METLogInCompletionHandler) {
    let profile = ["name" : name]
    
    self.signUpWithEmail(email, password: password, profile: profile, completionHandler: completionHandler)
  }
  
  // sign up with name, email and phone number
  // auto verify phone number if user signs up via mobile
  func signUpWithEmail(email: String, password: String, name: String, phone: String, completionHandler: METLogInCompletionHandler) {
    print("email: \(email)")
    print("password: \(password)")
    print("phone: \(phone)")
    print("name: \(name)")
    
    
    let profile: [NSObject: AnyObject] = ["name" : name,
                                          "phones": [
                                                      ["number": phone, "verified": false]
                                                    ]
                                         ]
    
    self.signUpWithEmail(email, password: password, profile: profile, completionHandler: completionHandler)
  }
  
}

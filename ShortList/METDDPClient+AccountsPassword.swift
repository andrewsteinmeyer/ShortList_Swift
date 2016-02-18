//
//  METDDPClient+AccountsPassword.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 2/18/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import Meteor

extension METDDPClient {
  
  func signUpWithEmail(email: String, password: String, name: String, completionHandler: METLogInCompletionHandler) {
    let profile = ["name" : name]
    
    self.signUpWithEmail(email, password: password, profile: profile, completionHandler: completionHandler)
  }
  
}

/*
- (void)signUpWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name completionHandler:(nullable METLogInCompletionHandler)completionHandler {
  NSMutableDictionary *profile = [NSMutableDictionary dictionary];
  name ? profile[@"name"] = name : nil;
  
  [self signUpWithEmail:email password:password profile:profile completionHandler:completionHandler];
  
}
*/
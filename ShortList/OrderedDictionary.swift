//
//  OrderedDictionary.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 2/24/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import Foundation

public struct OrderedDictionary<Tk: Hashable, Tv> {
  var keys: Array<Tk> = []
  var values: Dictionary<Tk,Tv> = [:]
  
  var count: Int {
    assert(keys.count == values.count, "Keys and values array out of sync")
    return self.keys.count;
  }
  
  // Explicitly define an empty initializer to prevent the default memberwise initializer from being generated
  init() {}
  
  subscript(index: Int) -> Tv? {
    get {
      let key = self.keys[index]
      return self.values[key]
    }
    set(newValue) {
      let key = self.keys[index]
      if (newValue != nil) {
        self.values[key] = newValue
      } else {
        self.values.removeValueForKey(key)
        self.keys.removeAtIndex(index)
      }
    }
  }
  
  subscript(key: Tk) -> Tv? {
    get {
      return self.values[key]
    }
    set(newValue) {
      if newValue == nil {
        self.values.removeValueForKey(key)
        _ = self.keys.filter {$0 != key}
      }
      
      let oldValue = self.values.updateValue(newValue!, forKey: key)
      if oldValue == nil {
        self.keys.append(key)
      }
    }
  }
  
  var description: String {
    var result = "{\n"
    for i in 0...self.count {
      result += "[\(i)]: \(self.keys[i]) => \(self[i])\n"
    }
    result += "}"
    return result
  }
}

extension OrderedDictionary: SequenceType {
  
  /// Creates a generator for each (key, value)
  public func generate() -> AnyGenerator<(Tk , Tv)> {
    var index = 0
    return anyGenerator({
      if index < self.count {
        let key = self.keys[index]
        let value = self[index]
        index++
        return (key, value!)
      } else {
        index = 0
        return nil
      }
    })
  }
}

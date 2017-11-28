//
//  Helpers.swift
//  PlayAround
//
//  Created by Eric Milhizer on 11/27/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit

class Helpers {
  
  static func checkIfSKSExists(forName baseName: String) -> String {
    
    var finalName = baseName
    
    if UIDevice.current.userInterfaceIdiom == .pad {
      if let _ = GameScene(fileNamed: baseName + "_Pad") {
        finalName += "_Pad"
      }
    }
    
    // .phone is default SKS name
    // Worry about TV form factor later
    
    return finalName
  } // checkIfSKSExists
  
  
  
  
  
  
} // Helpers






//
//  GameScene+Objects.swift
//  PlayAround
//
//  Created by Eric Milhizer on 11/30/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


extension GameScene {
  
  // Setup buildings, castle and other objects
  func setupGameObjects() {
    print("Setting up game objects")
    for node in children {
      if let itemFound = node as? WorldItem {
        setupItem(worldItem: itemFound)
      }
    }
  } // setupGameObjects
  
  func setupItem(worldItem: WorldItem) {
    print("Found item \(worldItem.name!)")
    guard let result = getPList(fromFile: "GameData.plist") else {
      fatalError("ERROR: Could not load Game Data plist file")
    }
    
    var foundLevelSpecificItem = false
    
    // Parse property list dictionary
    if let levelDict = result["Levels"] as? [String: Any] {
      for (key, value) in levelDict {
        if key == currentLevel {
          if let levelData = value as? [String: Any] {
            for (key, value) in levelData {
              if key == "Items" {
                if let itemsData = value as? [String: Any] {
                  for (key, value) in itemsData {
                    if key == worldItem.name {
                      print(" -- Matched Level-Specific item \(key)")
                      useDict(itemDict: value as! [String: Any],
                              withWorldItem: worldItem)
                      foundLevelSpecificItem = true
                      break
                    } // found item from scene to match GameData.plist
                  } // cycle through all item data
                } // get items dictionary
                break
              } // Level-specific Items
            } // for each element in level data
          } // level data
          break
        } // current level
      } // for each level
      
    } // parse "Levels" plist
    
    if !foundLevelSpecificItem {
      if let itemsData = result["Items"] as? [String: Any] {
        for (key, value) in itemsData {
          if key == worldItem.name {
            print(" -- Matched general item named \(key)")
            useDict(itemDict: value as! [String: Any],
                    withWorldItem: worldItem)
            break
          } // found general item in scene to match GameData.plist
        } // for each item
        
      } // parse "Items" plist
    }

  } // setupItem
  
  func useDict(itemDict: [String: Any], withWorldItem worldItem: WorldItem) {
    worldItem.setup(withDict: itemDict)
  }
  
  
  
} // GameScene+Objects

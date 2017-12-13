//
//  WorldItem.swift
//  PlayAround
//
//  Created by Eric Milhizer on 11/30/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


class WorldItem: SKSpriteNode {
  
  var isPortal = false
  var portalToLevel = ""
  var portalToWhere = ""
  var portalDelay = TimeInterval(0)
  var infoDisplayTime = TimeInterval(2)
  
  var isAltPortal = false
  var altPortalToLevel = ""
  var altPortalToWhere = ""
  var altPortalDelay = TimeInterval(0)
  
  var requiredThing = ""
  var requiredAmount = 0
  var deductOnEntry = false
  var timeToOpen = TimeInterval(0)
  var timerName = "OpenTimer" // Action name of timer progress bar
  
  var isOpen = true
  
  var lockedTexts = [String]()
  var unlockedTexts = [String]()
  var openTexts = [String]()
  var lockedIcon = ""
  var unlockedIcon = ""
  var openIcon = ""

  var currentText = ""
  
  var openAnimation = ""
  var openImage = ""
  
  var rewards = [String: Any]()
  var removeItems = [String: Any]()
  
  var deleteBody = false
  var deleteFromLevel = false
  
  var neverRewardAgain = false
  var neverShowAgain = false
  var remainOpen = false
  var removeText = false
  
  let defaults = UserDefaults.standard
  
  
  // Setup
  func setup(withDict dict: [String: Any]) {
    
    for (key, value) in dict {
      
      if let itemDict = value as? [String: Any], key == "Requires" {
        isOpen = false
        parseRequiredItem(withDict: itemDict)
      } // Requires
      
      else if let textDict = value as? [String: Any], key == "Text" {
        parseItemText(withDict: textDict)
      } // Text

      else if let portalDict = value as? [String: Any], key == "PortalTo" {
        parsePortalInfo(withDict: portalDict)
      } // PortalTo
        
      else if let altPortalDict = value as? [String: Any], key == "AltPortalTo" {
        parseAltPortalInfo(withDict: altPortalDict)
      } // AltPortalTo
        
      else if let appearanceDict = value as? [String: Any], key == "Appearance" {
        parseItemAppearance(withDict: appearanceDict)
      } // Appearance

      else if let rewardsDict = value as? [String: Any], key == "Rewards" {
        rewards = rewardsDict
      } // Appearance

      else if let afterContactDict = value as? [String: Any], key == "AfterContact" {
        parseAfterContact(withDict: afterContactDict)
      } // AfterContact

      else if let rememberToDict = value as? [String: Any], key == "RememberTo" {
        parseRememberTo(withDict: rememberToDict)
      } // RememberTo

      else if let removeWhen = value as? [String: Any], key == "RemoveWhen" {
        removeItems = removeWhen
      } // Appearance
      
    } // looping main dict
    
    // Setup physics
    physicsBody?.categoryBitMask = BodyType.Item
    physicsBody?.collisionBitMask = BodyType.Player
    physicsBody?.contactTestBitMask = BodyType.Player

    
    if requiredThing != "" {
      checkRequirements()
    }
    
    checkRemoveRequirements()
    
    if neverRewardAgain && defaults.bool(forKey: name! + "AlreadyAwarded") {
      rewards.removeAll()
    }
    if neverShowAgain && defaults.bool(forKey: name! + "NeverShowAgain") {
      removeFromParent()
    }
    if !isOpen && remainOpen && defaults.bool(forKey: name! + "RemainOpen") {
      open()
    }
    if !isOpen && removeText && defaults.bool(forKey: name! + "RemainOpen") {
      unlockedTexts.removeAll()
      lockedTexts.removeAll()
      openTexts.removeAll()
    }

  } // setup
  
  // Check item requirements
  func checkRequirements() {
    if defaults.integer(forKey: requiredThing) >= requiredAmount {
      open()
      // use open appearance
    } else {
      isOpen = false
      // use closed appearance
    }
  } // checkRequirements
  
  // Check if we should remove the item
  func checkRemoveRequirements() {
    for (key, value) in removeItems {
      if let removeItemQty = value as? Int {
        if defaults.integer(forKey: key) >= removeItemQty {
          removeFromParent()
        }
      }
      
    } // loop through removeItems
    
  } // checkRemoveRequirements
  
  // Get "remember to" behave this way after items been contacted or open
  func parseRememberTo(withDict dict: [String: Any]) {
    for (key, value) in dict {
      if let value = value as? Bool, key == "NeverRewardAgain" {
        neverRewardAgain = value
      } else if let value = value as? Bool, key == "NeverShowAgain" {
        neverShowAgain = value
      } else if let value = value as? Bool, key == "RemainOpen" {
        remainOpen = value
      } else if let value = value as? Bool, key == "RemoveText" {
        removeText = value
      }
    }
  } // parseAfterContact
  
  // Get after-contact rules
  func parseAfterContact(withDict dict: [String: Any]) {
    for (key, value) in dict {
      if let value = value as? Bool, key == "DeleteFromLevel" {
        deleteFromLevel = value
      } else if let value = value as? Bool, key == "DeleteBody" {
        deleteBody = value
      }
    }
  } // parseAfterContact
  
  // Get Appearance
  func parseItemAppearance(withDict dict: [String: Any]) {
    for (key, value) in dict {
      if let value = value as? String, key == "OpenImage" {
        openImage = value
      } else if let value = value as? String, key == "OpenAnimation" {
        openAnimation = value
      }
    }
  } // parseItemAppearance

  // Get Portal To info
  func parsePortalInfo(withDict dict: [String: Any]) {
    for (key, value) in dict {
      if let value = value as? String, key == "Level" {
        portalToLevel = value
        isPortal = true
        print("  -- Found portal to level: \(portalToLevel)")
      } else if let value = value as? String, key == "Where" {
        portalToWhere = value
        isPortal = true
        print("  -- Found portal to where: \(portalToWhere)")
      } else if let value = value as? TimeInterval, key == "Delay" {
        portalDelay = value
        print("  -- Found portal delay: \(portalDelay)")
      }
    } // loop through portal info dict

  } // parsePortalInfo
  
  // Get Alt Portal To info
  func parseAltPortalInfo(withDict dict: [String: Any]) {
    for (key, value) in dict {
      if let value = value as? String, key == "Level" {
        altPortalToLevel = value
        isAltPortal = true
        print("  -- Found alt portal to level: \(altPortalToLevel)")
      } else if let value = value as? String, key == "Where" {
        altPortalToWhere = value
        isAltPortal = true
        print("  -- Found portal to where: \(altPortalToWhere)")
      } else if let value = value as? TimeInterval, key == "Delay" {
        altPortalDelay = value
        print("  -- Found portal delay: \(altPortalDelay)")
      }
    } // loop through alt portal info dict
    
  } // parseAltPortalInfo
  
  // Get Required Item Info
  func parseRequiredItem(withDict dict: [String: Any]) {
    
    for (key, value) in dict {
      
      if let theThing = value as? String, (key == "Inventory" || key == "Thing") {
        requiredThing = theThing
      } // Inventory item
      else if let theAmount = value as? Int, key == "Amount" {
        requiredAmount = theAmount
      } // Inventory amount
      else if let theDeduct = value as? Bool, key == "DeductOnEntry" {
        deductOnEntry = theDeduct
      } // Inventory deduct on entry
      else if let timeToOpen = value as? TimeInterval, key == "TimeToOpen" {
        self.timeToOpen = timeToOpen
      } // Inventory time to open
      else if let timerName = value as? String, key == "TimerName" {
        self.timerName = timerName
      } // Inventory time to open

    } // loop through dict
    
  } // parseRequiredItem
  
  // Get item text info
  func parseItemText(withDict dict: [String: Any]) {
    
    for (key, value) in dict {
      print("-- Item name: \(name!); Text Key: \(key); Text Value: \(value)")
      // Texts
      if let lockedTexts = value as? [String], key == "Locked" {
        self.lockedTexts = lockedTexts
      }
      else if let lockedText = value as? String, key == "Locked" {
        lockedTexts.append(lockedText)
      }
      else if let unlockedTexts = value as? [String], key == "Unlocked" {
        self.unlockedTexts = unlockedTexts
      }
      else if let unlockedText = value as? String, key == "Unlocked" {
        unlockedTexts.append(unlockedText)
      }
      else if let openTexts = value as? [String], key == "Open" {
        self.openTexts = openTexts
      }
      else if let openText = value as? String, key == "Open" {
        openTexts.append(openText)
      }
      
      // Icons
      else if let icon = value as? String, key == "LockedIcon" {
        lockedIcon = icon
      }
      else if let icon = value as? String, key == "UnlockedIcon" {
        unlockedIcon = icon
      }
      else if let icon = value as? String, key == "OpenIcon" {
        openIcon = icon
      }
      
      // How long to keep/fade out info text
      else if let displayTime = value as? TimeInterval, key == "Time" {
        infoDisplayTime = displayTime
      }


      
    } // loop through dict
        
  } // parseItemText

  // Return the text when contacting this item
  func getText() -> String {
    
    if currentText == "" {
      if (!isOpen) && (lockedTexts.count > 0) {
        let randomLine = Int(arc4random_uniform(UInt32(lockedTexts.count)))
        currentText = lockedTexts[randomLine]
      } else if openTexts.count > 0 {
        let randomLine = Int(arc4random_uniform(UInt32(openTexts.count)))
        currentText = openTexts[randomLine]
      }
    }
    
    return currentText
  } // getText

  // Return the text when contacting this item if it's unlocked
  func getUnlockedText() -> String {
    
    print("---- Current Text: \(currentText)")
    print("---- UnlockedTexts.count = \(unlockedTexts.count)")
    if (currentText == "") && (unlockedTexts.count > 0) {
      let randomLine = Int(arc4random_uniform(UInt32(unlockedTexts.count)))
      currentText = unlockedTexts[randomLine]
      print("---- Current Text: \(currentText)")
    }
    
    return currentText
  } // getText

  // Open the item
  func open() {
    isOpen = true
    
    if openAnimation != "" {
      run(SKAction(named: openAnimation)!)
    } else if (openImage != "") {
      texture = SKTexture(imageNamed: openImage)
    }
    
    if remainOpen {
      defaults.set(true, forKey: name! + "RemainOpen")
    }
  } // open
  
  // After open contact
  func afterOpenContact() {
    print("-- After open contact with \(name!)")
    if deleteBody {
      physicsBody = nil
    } else if deleteFromLevel {
      removeFromParent()
    }
    
    if isOpen {

      if deductOnEntry {
        print("  -- Deduct \(name!) on entry")
        if defaults.integer(forKey: requiredThing) != 0 {
          // stop multi-contact from mutl-deducting by accident
          deductOnEntry = false
          let currentAmount = defaults.integer(forKey: requiredThing)
          let newAmount = currentAmount - requiredAmount
          print("Set \(requiredThing) amount to \(newAmount)")
          defaults.set(newAmount, forKey: requiredThing)
        } // required thing != 0
        
      } // deduct on entry
      
      if neverShowAgain {
        print("  -- Never show \(name!) again")
        defaults.set(true, forKey: name! + "NeverShowAgain")
      }
      if removeText {
        defaults.set(true, forKey: name! + "RemoveText")
      }

    } // is open
    
  } // afterOpenContact
  
  
  
  
} // WorldItem















//
//  GameScene+Inventory.swift
//  PlayAround
//
//  Created by Eric Milhizer on 12/4/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


extension GameScene {
  
  // Get rewards info
  // Get Required Item Info
  func parseItemRewards(withDict dict: [String: Any]) {
    
    for (key, value) in dict {
      if let health = value as? Int, key == "Health" {
        increaseHealth(byAmount: health)
      }
      else if let armor = value as? Int, key == "Armor" {
        increaseArmor(byAmount: armor)
      }
      else if let xp = value as? Int, key == "XP" {
        increaseXP(byAmount: xp)
      }
      else if let currency = value as? Int, key == "Currency" {
        increaseCurrency(byAmount: currency)
      }
      else if let playerClass = value as? String, key == "ClassName", playerClass != "" {
        changeClass(toNewClass: playerClass)
      }
      
      // Catch all (named) inventory items that have a numberical (qty) reward
      else if let newAmount = value as? Int {
        addToInventory(withName: key, andAmount: newAmount)
      }
      
    } // loop through dict
    
  } // getRequiredItemInfo

  // Increase stats
  func increaseHealth(byAmount amount: Int) {
    thePlayer.currentHealth += amount
    thePlayer.currentHealth = min(thePlayer.currentHealth, thePlayer.maxHealth)
    defaults.set(thePlayer.currentHealth, forKey: "CurrentHealth")
    updateStatsLabels()
  }
  
  func increaseArmor(byAmount amount: Int) {
    thePlayer.currentArmor += amount
    thePlayer.currentArmor = min(thePlayer.currentArmor, thePlayer.maxArmor)
    defaults.set(thePlayer.currentArmor, forKey: "CurrentArmor")
    updateStatsLabels()
  }
  
  func increaseXP(byAmount amount: Int) {
    thePlayer.currentXP += amount
    defaults.set(thePlayer.currentXP, forKey: "CurrentXP")
    
    // Level up
    if thePlayer.currentXP >= thePlayer.maxXP {
      thePlayer.currentXPLevel += 1
      loadXPInfo(forCurrentXPLevel: thePlayer.currentXPLevel)
      defaults.set(thePlayer.currentXPLevel, forKey: "CurrentXPLevel")
    }    
    
    updateStatsLabels()
  }
  
  func increaseCurrency(byAmount amount: Int) {
    thePlayer.currency += amount
    defaults.set(thePlayer.currency, forKey: "Currency")
    updateStatsLabels()
  }
  
  func changeClass(toNewClass className: String) {
    thePlayer.currentClass = className
    defaults.set(thePlayer.currentClass, forKey: "CurrentClass")
    parsePropertyListForPlayer(className: className)
    updateStatsLabels()
  }
  
  // Found an item, add it to player inventory
  func addToInventory(withName inventoryName: String, andAmount amount: Int) {
    
    var newAmount = amount
    
    if defaults.integer(forKey: inventoryName) != 0 {
      newAmount += defaults.integer(forKey: inventoryName)
    }
    print("Set \(inventoryName) amount to \(newAmount)")
    defaults.set(newAmount, forKey: inventoryName)
    checkItemMightOpen(withInventory: inventoryName, requiredAmount: newAmount)
    
  } // addToInventory
  
  // Check if found item might open a World Item
  func checkItemMightOpen(withInventory inventory: String, requiredAmount amount: Int) {
    
    for node in children {
      if let item = node as? WorldItem,
        !item.isOpen,
        inventory == item.requiredThing,
        amount >= item.requiredAmount {
        
        print("Contacted Item: \(inventory); that opens \(item.name!)")
        print("Will speak: \(item.unlockedTexts)")
        
        item.open()
        
        if item.unlockedTexts.count > 0 {
          displaySpeech(withText: item.getUnlockedText())
          if item.unlockedIcon != "" {
            displaySpeechIcon(withTextureName: item.unlockedIcon)
          }
        }
      } // if item is closed, required, has enough
    } // loop through all nodes in scene
    
  } // checkItemMightOpen






} // GameScene+Inventory










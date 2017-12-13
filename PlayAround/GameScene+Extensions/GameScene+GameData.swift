//
//  GameScene+GameData.swift
//  PlayAround
//
//  Created by Eric Milhizer on 11/27/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit



extension GameScene {
  
  func setupGameData() {
    
    guard let result = getPList(fromFile: "GameData.plist") else {
      fatalError("ERROR: Could not load Game Data plist file")
    }
    print("Game Data:")
    print(result)
    
    // Parse property list dictionary
    if let levelDict = result["Levels"] as? [String: Any] {
      for (key, value) in levelDict {
        print("Key: \(key)")
        if key == currentLevel {
          print("--- Loading Current Level ---")
          if let levelData = value as? [String: Any] {
            for (key, value) in levelData {
              print("Key: \(key)")
              
              if let npcDict = value as? [String: Any], key == "NPC" {
                createNPC(withDict: npcDict)
              } // NPC data
              else if let propertiesDict = value as? [String: Any], key == "Properties" {
                parseLevelSpecificProperties(withDict: propertiesDict)
              } // Properties
              else if let rewardsDict = value as? [String: Any], key == "Rewards" {
                rewards = rewardsDict
              } // Rewards
              else if let clearArray = value as? [String], key == "Clear" {
                clearItems = clearArray
              } // Clear

              
            } // for each element in level data
          } // level data
        } // current level
      } // fore each level
      
    } // parse plist
    
  } // setupGameData
  
  // Create the NPC
  func createNPC(withDict dict: [String: Any]) {
    
    for (key, value) in dict {
      
      // If NPC created in scene, then don't re-create
      var npcAlreadyInScene = false
      
      for node in children {
        if let newNPC = node as? NPC, newNPC.name == key {
          useDict(withNPC: newNPC, andDict: value as! [String: Any])
          npcAlreadyInScene = true
          break
        }
      }
      
      if !npcAlreadyInScene {
        var baseImage = ""
        var range = ""
        let nickname = key
        
        guard let NPCData = value as? [String: Any] else {
          print("NPC Data not a dictionary")
          return
        }
        
        for (key, value) in NPCData {
          if key == "BaseImage" {
            baseImage = value as! String
          }
          else if key == "Range" {
            range = value as! String
          }
        }
        
        let newNPC = NPC(imageNamed: baseImage)
        newNPC.name = nickname
        newNPC.setup(withDict: value as! [String: Any])
        newNPC.baseFrame = baseImage
        newNPC.zPosition = thePlayer.zPosition - 1
        newNPC.position = putSpriteWithinRange(nodeName: range)
        
        newNPC.alreadyContacted =
          defaults.bool(forKey: currentLevel+nickname+"alreadyContacted")
        
        addChild(newNPC)
      } // NPC not already added in scene
    } // for each NPC entry
    
  } // createNPC
  
  // Setup NPC that's been created by scenekit editor
  func useDict(withNPC npc: NPC, andDict dict: [String: Any]) {
    for (key, value) in dict {
      if key == "Rnage" {
        npc.position = putSpriteWithinRange(nodeName: value as! String)
      }
      if key == "BaseImage" {
        npc.baseFrame = value as! String
      }
    }
    npc.setup(withDict: dict)
    npc.zPosition = thePlayer.zPosition - 1
    npc.alreadyContacted = defaults.bool(forKey: currentLevel + npc.name! + "alreadyContacted")
  } // useDict:withNPC
  
  // Parse the Level Properties
  func parseLevelSpecificProperties(withDict dict: [String: Any]) {
    
    for (key, value) in dict {
      if let value = value as? Bool, key == "CameraFollowsPlayer" {
        cameraFollowsPlayer = value
      } else if let value = value as? String, key == "CameraOffset" {
        cameraOffset = CGPointFromString(value)
        print("Camera Offset: \(value) -- \(cameraOffset)")
      } else if let value = value as? Bool, key == "ContinuePoint" {
        if value {
          defaults.set(currentLevel, forKey: "ContinuePoint")
        }
      } else if let value = value as? Bool, key == "DisableAttack" {
        disableAttack = value
      }

    } // loop through Level Property fields
    
  } // parseLevelSpecificProperties

  
  // Put sprite at random position with a named node (range)
  func putSpriteWithinRange(nodeName: String) -> CGPoint {
    
    var point = CGPoint.zero
    
    for node in children {
      if node.name == nodeName {
        if let rangeNode = node as? SKSpriteNode {
          let nodeWidth = rangeNode.size.width
          let nodeHeight = rangeNode.size.height
          let randomX = arc4random_uniform(UInt32(nodeWidth))
          let randomY = arc4random_uniform(UInt32(nodeHeight))
          let posStartX = rangeNode.position.x - (rangeNode.size.width / 2)
          let posStartY = rangeNode.position.y - (rangeNode.size.height / 2)
          point = CGPoint(x: posStartX + CGFloat(randomX),
                          y: posStartY + CGFloat(randomY))
        }
        break // found it
      }
    }
    return point
  } // putSpriteWithinRange

  
  // MARK: - Get Property List data file info
  func getPList(fromFile fileName: String) -> [String: Any]? {
    // If fileName doesn't have .plist then add it
    var finalFileName = fileName
    if let fileURL = URL(string: fileName), fileURL.pathExtension == "plist" {
      print("Removing plist file extension")
      finalFileName = (fileURL.deletingPathExtension)().absoluteString
    }
    print("Final File Name: \(finalFileName)")
    
    guard let fileURL = Bundle.main.url(forResource: finalFileName,
                                        withExtension: "plist") else {
                                          print("Could not find PList file: \(fileName).plist")
                                          return nil
    }
    guard let data = try? Data(contentsOf: fileURL) else {
      print("Could not find PList data in file: \(fileURL)")
      return nil
    }
    
    guard let result = try?
      PropertyListSerialization.propertyList(
        from: data,
        options: [],
        format: nil) as? [String: Any]
    else {
      print("PList data not in correct format: \(data)")
      return nil
    }
    
    return result
  } // getPList

  
  
  
} // GameScene+GameData







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
              if key == "NPC" {
                createNPC(withDict: value as! [String: Any])
              } // NPC data
            } // for each element in level data
          } // level data
        } // current level
      } // fore each level
      
    } // parse plist
    
  } // setupGameData
  
  func createNPC(withDict dict: [String: Any]) {
    
    for (key, value) in dict {
      
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
      
      addChild(newNPC)
      
    } // for each NPC entry
    
  } // createNPC
  
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







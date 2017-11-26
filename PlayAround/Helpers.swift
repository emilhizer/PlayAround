//
//  Helpers.swift
//  PlayAround
//
//  Created by Eric Milhizer on 11/24/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit



extension GameScene {
  
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
      PropertyListSerialization.propertyList(from: data,
                                             options: [],
                                             format: nil) as?
                                              [String: Any] else {
      print("PList data not in correct format: \(data)")
      return nil
    }
    return result
  } // getPList
  
  
  
  //MARK: - Analyse the collision/contact set up.
  func checkPhysics() {
    
    // Create an array of all the nodes with physicsBodies
    var physicsNodes = [SKNode]()
    
    //Get all physics bodies
    for node in children {
      if let _ = node.physicsBody {
        physicsNodes.append(node)
      } else {
        let nodeName = node.name ?? "No Name"
        print("\(nodeName) does not have a physics body so cannot collide or be involved in contacts.")
      }
    }
    
    //For each node, check it's category against every other node's collion and contctTest bit mask
    for node in physicsNodes {
      let category = node.physicsBody!.categoryBitMask
      // Identify the node by its category if the name is blank
      let nodeName = node.name ?? "Category \(category)"
      let collisionMask = node.physicsBody!.collisionBitMask
      let contactMask = node.physicsBody!.contactTestBitMask
      
      // If all bits of the collisonmask set, just say it collides with everything.
      if collisionMask == UInt32.max {
        print("\(nodeName) collides with everything")
      }
      
      for otherNode in physicsNodes {
        if (node != otherNode) && (node.physicsBody?.isDynamic == true) {
          let otherCategory = otherNode.physicsBody!.categoryBitMask
          // Identify the node by its category if the name is blank
          let otherName = otherNode.name ?? "Category \(otherCategory)"
          
          // If the collisonmask and category match, they will collide
          if ((collisionMask & otherCategory) != 0) && (collisionMask != UInt32.max) {
            print("\(nodeName) collides with \(otherName)")
          }
          // If the contactMAsk and category match, they will contact
          if (contactMask & otherCategory) != 0 {print("\(nodeName) notifies when contacting \(otherName)")}
        }
      }
    }
  } // checkPhysics

} // Extension GameScene

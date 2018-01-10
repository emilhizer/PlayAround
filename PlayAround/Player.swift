//
//  Player.swift
//  PlayAround
//
//  Created by Eric Milhizer on 12/15/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


class Player: SKSpriteNode {
  
  var frontWalk = ""
  var frontIdle = ""
  var frontMelee = ""
  
  var backWalk = ""
  var backIdle = ""
  var backMelee = ""
  
  var leftWalk = ""
  var leftIdle = ""
  var leftMelee = ""
  
  var rightWalk = ""
  var rightIdle = ""
  var rightMelee = ""
  
  var meleeAnimationName = "Attacking"
  var meleeScaleSize = CGFloat(2)
  var meleeAnimationSize = CGSize(width: 100, height: 100)
  var meleeTimeBetweenUse = TimeInterval(0)
  var meleeDamage = 1
  
  var walkSpeedOnPath = CGFloat(200) // default is 200 pxl/second
  var walkSpeed = CGFloat(150) // speed when not on path
  var immunityTime = TimeInterval(1)
  
  var currentHealth = 0
  var maxHealth = 0
  var currentArmor = 0
  var maxArmor = 0
  var currentXP = 0
  var maxXP = 0
  var currentXPLevel = 0
  var currentXPLevelName = ""
  var currency = 0
  var currentClass = ""
  
  var currentProjectileName = ""


  func setup(withDict dict: [String: Any]) {
    print("  -- Setting up player with dict: \(dict)")
    
    for (key, value) in dict {
      
      if let animDict = value as? [String: Any], key == "Animation" {
        for (key, value) in animDict {
          if key == "Back" {
            if let dict = value as? [String: Any] {
              for (key, value) in dict {
                switch key {
                  case "Walk":
                    backWalk = value as! String
                  case "Idle":
                    backIdle = value as! String
                  case "Melee":
                    backMelee = value as! String
                  default:
                    print("Unknown key found: \(key)")
                }
              }
            }
          } // key = Back
          if key == "Front" {
            if let dict = value as? [String: Any] {
              for (key, value) in dict {
                switch key {
                case "Walk":
                  frontWalk = value as! String
                case "Idle":
                  frontIdle = value as! String
                case "Melee":
                  frontMelee = value as! String
                default:
                  print("Unknown key found: \(key)")
                }
              }
            }
          } // key = Front
          if key == "Left" {
            if let dict = value as? [String: Any] {
              for (key, value) in dict {
                switch key {
                case "Walk":
                  leftWalk = value as! String
                case "Idle":
                  leftIdle = value as! String
                case "Melee":
                  leftMelee = value as! String
                default:
                  print("Unknown key found: \(key)")
                }
              }
            }
          } // key = Left
          if key == "Right" {
            if let dict = value as? [String: Any] {
              for (key, value) in dict {
                switch key {
                case "Walk":
                  rightWalk = value as! String
                case "Idle":
                  rightIdle = value as! String
                case "Melee":
                  rightMelee = value as! String
                default:
                  print("Unknown key found: \(key)")
                }
              }
            }
          } // key = Right
        } // cycle through animDict
      } // Animation
      
//      if let soundsDict = value as? [String: Any], key == "Sounds" {
//
//      } // Sounds

      if let meleeDict = value as? [String: Any], key == "Melee" {
        for (key, value) in meleeDict {
          if let value = value as? Int, key == "Damage" {
            meleeDamage = value
          }
          if let value = value as? String, key == "Size" {
            meleeAnimationSize = CGSizeFromString(value)
          }
          if let value = value as? String, key == "Animation" {
            meleeAnimationName = value
          }
          if let value = value as? CGFloat, key == "ScaleTo" {
            meleeScaleSize = value
          }
          if let value = value as? TimeInterval, key == "TimeBetweenUse" {
            meleeTimeBetweenUse = value
          }
        } // cycle through meleeDict
      } // Melee

      if let rangedDict = value as? [String: Any], key == "Ranged" {
        if let value = rangedDict["Projectile"] as? String {
          currentProjectileName = value
        }
      } // Ranged

      if let statsDict = value as? [String: Any], key == "Stats" {
        if let value = statsDict["ClassName"] as? String {
          currentClass = value
        }
        if let value = statsDict["PathSpeed"] as? CGFloat {
          walkSpeedOnPath = value
        }
        if let value = statsDict["Speed"] as? CGFloat {
          walkSpeed = value
        }
        if let value = statsDict["MaxHealth"] as? Int {
          maxHealth = value
          currentHealth = maxHealth // set current health to max health
        }
        if let value = statsDict["MaxArmor"] as? Int {
          maxArmor = value
          currentArmor = maxArmor
        }
        if let value = statsDict["Immunity"] as? TimeInterval {
          immunityTime = value
        }
      } // Stats

      
      
    } // cycle through player dict
    
    
    
    
    
  } // setup

  
  
  
  
} // Player










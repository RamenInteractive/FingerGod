//
//  SingleUnit.swift
//  FingerGod
//
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import UIKit

//unit three style，people,follower,demigod
enum Character {
    case PEOPLE
    case FOLLOWER
    case DEMIGOD
}

class SingleUnit: NSObject {
    
    var hp : Float = 100 //hp
    var maxHP : Float = 100
    var character: Character?
    var dead = false
    var attack : Float = 10
    var modelInstance : ModelInstance?
    
    public func attack(targetGroup: UnitGroup) {
        // Default attack behaviour
        // 10% chance to attack, 90% chance to do nothing
        if (arc4random_uniform(10) >= 1) {
            return
        }
        let targets = targetGroup.peopleArray
        
        // If there are no people in the enemy army left, don't attack
        if (targets.count == 0) {
            return
        }
        let target = targets[Int(arc4random_uniform(UInt32(targets.count)))] as! SingleUnit
        
        target.hurt(attack)
    }
    
    public func hurt(_ damage: Float) {
        // Default hurt behaviour
        hp = hp - damage
        if (hp <= 0) {
            die()
        }
    }
    
    public func heal(_ recovery: Float) {
        // Default healing behaviour
        hp = hp + recovery
        if (hp > maxHP) {
            hp = maxHP
        }
    }
    
    public func die() {
        // Default death behaviour
        dead = true
    }
    
    public func battleEnd() {
        // Default end-of-battle behaviour
    }
    
    public func getModelName() -> String {
        // Name of the model this unit uses
        return "UnitToken"
    }
}


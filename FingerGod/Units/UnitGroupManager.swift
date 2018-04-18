    //
//  UnitGroupManagerComponent.swift
//  FingerGod
//
//  Created by Aaron F on 2018-04-15.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import UIKit

public class UnitGroupManager : NSObject, Subscriber {
    public var unitGroups : [UnitGroupComponent] = []
    public var map : MapComponent
    public var game : Game
    
    public init(_ newGame : Game, _ newMap: MapComponent) {
        map = newMap
        game = newGame
        super.init()
        EventDispatcher.subscribe("AddUnit", self)
        EventDispatcher.subscribe("RemoveUnit", self)
        EventDispatcher.subscribe("UnitMoved", self)
        EventDispatcher.subscribe("BattleEnd", self)
        EventDispatcher.subscribe("PowerTileGroup", self)
        EventDispatcher.subscribe("DamageUnit", self)
        EventDispatcher.subscribe("ChangeTile", self)
        EventDispatcher.subscribe("SplitUnit", self)
    }
    
    func notify(_ eventName: String, _ params: [String : Any]) {
        switch(eventName) {
        case "AddUnit":
            let unit = params["unit"] as! UnitGroupComponent
            unitGroups.append(unit)
            break
        case "UnitMoved":
            let unit = params["unit"] as! UnitGroupComponent
            let newPos = params["newPos"] as! Point2D
            let oldPos = params["oldPos"] as? Point2D
            
            if (map.getTile(pos: newPos) != nil) {
                if(map.getTile(pos: newPos)!.type == Tile.types.structure) {
                    let city = map.getTile(pos: newPos)!.getStructure()! as! City
                    if(city.owner.id == unit.owner!.id) {
                        city.returnUnits(unit)
                    } else {
                        // TODO: Fight Enemy Castle
                    }
                } else {
                    let unitsAtNewPos = unitsAtLocation(newPos)
                    
                    if (unitsAtNewPos.count > 0) {
                        for otherUnit in unitsAtNewPos {
                            if (unit !== otherUnit && unit.owner!.id == otherUnit.owner!.id) {
                                // Ally Merge code
                                for u in otherUnit.unitGroup.peopleArray{
                                    let newU = u as! SingleUnit
                                    if (newU.modelInstance != nil) {
                                        Renderer.removeInstance(inst: newU.modelInstance!)
                                        newU.modelInstance = nil
                                    }
                                    unit.unitGroup.peopleArray.add(newU)
                                }
                                EventDispatcher.publish("RemoveUnit", ("unit", otherUnit))
                                unit.updateModels()
                            } else if (unit.owner!.id != otherUnit.owner!.id) {
                                print("BATTLE START")
                                startBattle(unit, otherUnit)
                            }
                        }
                    }
                }
            }
            
            if (oldPos != nil && unitsAtLocation(oldPos!).count == 0) {
                EventDispatcher.publish("ResetTileType", ("pos", oldPos!))
            }
            EventDispatcher.publish("SetTileType", ("pos", newPos), ("type", Tile.types.occupied), ("perma", false))
            
            break
        case "RemoveUnit":
            let unit = params["unit"] as! UnitGroupComponent
            game.removeGameObject(gameObject: unit.gameObject)
            let ind = unitGroups.index{$0 === unit};
            if (ind != nil) {
                unitGroups.remove(at: ind!)
                EventDispatcher.publish("ResetTileType", ("pos", Point2D(unit.position[0], unit.position[1])))
            }
            break
        case "BattleEnd":
            print("BATTLE END")
            let result = params["result"] as! String
            var groupA = params["groupA"] as! UnitGroupComponent
            var groupB = params["groupB"] as! UnitGroupComponent
            switch(result) {
            case "awin", "tie":
                for d in groupA.unitGroup.deactivatedDemigods {
                    groupA.unitGroup.peopleArray.add(d)
                    if (d.hp <= 0) {
                        d.hp = 1
                    }
                    d.dead = false
                    if (d.modelInstance != nil) {
                        Renderer.removeInstance(inst: d.modelInstance!)
                        d.modelInstance = nil
                    }
                }
                for d in groupB.unitGroup.deactivatedDemigods {
                    if (d.power != nil) {
                        groupB.owner?.removePower(d.power!)
                    }
                    groupA.unitGroup.peopleArray.add(d)
                    d.power = groupA.owner?.addPowerByName(d.powerName)
                    if (d.hp <= 0) {
                        d.hp = 1
                    }
                    d.dead = false
                    if (d.modelInstance != nil) {
                        Renderer.removeInstance(inst: d.modelInstance!)
                        d.modelInstance = nil
                    }
                }
                groupA.updateModels()
                EventDispatcher.publish("RemoveUnit", ("unit", groupB))
                groupA.offset(0.65, 0, 0)
                groupA.haltCounter -= 1
                groupA.unitGroup.deactivatedDemigods = [Demigod]()
                groupB.unitGroup.deactivatedDemigods = [Demigod]()
                groupA.owner!._gold += 10
                break
            case "bwin":
                for d in groupB.unitGroup.deactivatedDemigods {
                    groupB.unitGroup.peopleArray.add(d)
                    if (d.hp <= 0) {
                        d.hp = 1
                    }
                    d.dead = false
                    if (d.modelInstance != nil) {
                        Renderer.removeInstance(inst: d.modelInstance!)
                        d.modelInstance = nil
                    }
                }
                for d in groupA.unitGroup.deactivatedDemigods {
                    if (d.power != nil) {
                        groupA.owner?.removePower(d.power!)
                    }
                    groupB.unitGroup.peopleArray.add(d)
                    d.power = groupB.owner?.addPowerByName(d.powerName)
                    if (d.hp <= 0) {
                        d.hp = 1
                    }
                    d.dead = false
                    if (d.modelInstance != nil) {
                        Renderer.removeInstance(inst: d.modelInstance!)
                        d.modelInstance = nil
                    }
                    groupB.updateModels()
                }
                EventDispatcher.publish("RemoveUnit", ("unit", groupA))
                groupB.offset(-0.65, 0, 0)
                groupB.haltCounter -= 1
                groupA.unitGroup.deactivatedDemigods = [Demigod]()
                groupB.unitGroup.deactivatedDemigods = [Demigod]()
                groupB.owner!._gold += 10
                break
            default:
                break
            }
            break
            
        case "DamageUnit":
            let tile = params["tile"] as! Tile
            let damage =  params["damage"] as! Float
            let owner = params["owner"] as! Int
            for c in (unitGroups) {
                if Point2D(c.position) == tile.getAxial() {
                    if (c.owner!.id != owner) {
                        for u in (c.unitGroup.peopleArray) {
                            let unit = u as! SingleUnit
                            unit.hurt(damage)
                        }
                        c.updateModels()
                        let left = c.unitGroup.removeDeadUnits()
                        if left == 0 {
                            EventDispatcher.publish("RemoveUnit", ("unit", c))
                        }
                    }
                }
            }
        break
            
        case "HealUnit":
            let tile = params["tile"] as! Tile
            let heal =  params["heal"] as! Float
            let owner = params["owner"] as! Int
            for c in (unitGroups) {
                if Point2D(c.position) == tile.getAxial() {
                    if (c.owner!.id != owner) {
                        for u in (c.unitGroup.peopleArray) {
                            let unit = u as! SingleUnit
                            unit.heal(heal)
                        }
                    }
                }
            }
            break
        
        case "SplitUnit":
            let tile = params["unitGroup"] as! UnitGroupComponent
            let index = params["index"] as! Int
            let btn = params["btn"] as! UIButton
            var original = map.getTile(pos: Point2D(tile.position))!.getNeighbours()
            var shuffled = [Tile]()
            while(original.count > 0) {
                let index = Int(arc4random_uniform(UInt32(original.count)))
                if(original[index].type == Tile.types.vacant) {
                    shuffled.append(original[index])
                }
                original.remove(at: index)
            }
            if(shuffled.count > 0) {
                let place = shuffled[Int(arc4random_uniform(UInt32(shuffled.count)))]
                let pos = place.getAxial()
                
                let unitGroup = GameObject()
                unitGroup.addComponent(type: UnitGroupComponent.self)
                game.addGameObject(gameObject: unitGroup)
                
                let unitGroupComponent = unitGroup.getComponent(type: UnitGroupComponent.self)
                unitGroupComponent?.move(pos.x, pos.y)
                unitGroupComponent?.setOwner(tile.owner!)
                
                let max = min((index + 1) * 5, tile.unitGroup.peopleArray.count)
                let minI = index * 5
                
                print("max: " + String(max) + ", count: " + String(tile.unitGroup.peopleArray.count))
                
                if (index * 5 < max) {
                    for _ in (index * 5)..<max {
                        let unit = tile.unitGroup.peopleArray[minI] as! SingleUnit
                        tile.unitGroup.peopleArray.removeObject(at: minI)
                        if (unit.modelInstance != nil) {
                            Renderer.removeInstance(inst: unit.modelInstance!)
                            unit.modelInstance = nil
                        }
                        unitGroupComponent?.unitGroup.peopleArray.add(unit)
                    }
                }
                if(tile.unitGroup.peopleArray.count == 0) {
                    EventDispatcher.publish("RemoveUnit", ("unit", tile))
                    let index = unitGroups.index{$0 === tile}
                    if (index != nil) {
                        unitGroups.remove(at: index!)
                    }
                }
                unitGroups.append(unitGroupComponent!)
                unitGroupComponent?.updateModels()
                tile.updateModels()
                btn.removeFromSuperview()
            }
            break
            
        default:
            break
        }
    }
    
    private func startBattle(_ unitGroupA : UnitGroupComponent, _ unitGroupB : UnitGroupComponent) {
        unitGroupA.offset(-0.65, 0, 0)
        unitGroupB.offset(0.65, 0, 0)
        
        unitGroupA.setPosition(unitGroupA.position[0], unitGroupA.position[1], false)
        unitGroupB.setPosition(unitGroupB.position[0], unitGroupB.position[1], false)
        
        unitGroupA.haltCounter += 1
        unitGroupB.haltCounter += 1
        
        var battleObj = GameObject()
        
        battleObj.addComponent(type: BattleComponent.self)
        
        var battleComp = battleObj.getComponent(type: BattleComponent.self)
        battleComp?.groupA = unitGroupA
        battleComp?.groupB = unitGroupB
        
        game.addGameObject(gameObject: battleObj)
        battleComp?.start()
    }
    
    private func unitsAtLocation(_ pos: Point2D) -> [UnitGroupComponent] {
        var units : [UnitGroupComponent] = []
        for unit in unitGroups {
            if (Point2D(unit.position[0], unit.position[1]) == pos) {
                units.append(unit)
            }
        }
        return units
    }

}

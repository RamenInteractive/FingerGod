//
//  City.Swift
//  FingerGod
//
//  Created by Matthew Taylor on 2018-03-28.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import GLKit

public class City: Structure {
    public let owner : PlayerObject
    
    public init(_ pos: Point2D, _ owner: PlayerObject) {
        var castle : Model?
        
        do {
            castle = try ModelReader.read(objPath: "Castle")
        } catch {
            print("There was a problem initializing this tile model: \(error)")
        }
        
        let mi = ModelInstance(model: castle!)
        mi.color = owner.color
        Renderer.addInstance(inst: mi)
        
        self.owner = owner
        
        super.init(pos, mi)
        
        self.hp = 50
    }
    
    public override func interact() {
        dispatchUnitGroup(size: 10)
    }
    
    public func returnUnits(_ unitGroup: UnitGroupComponent) {
        var demigods = [SingleUnit]()
        let units = unitGroup.unitGroup.peopleArray.count
        
        for u in unitGroup.unitGroup.peopleArray {
            let unit = u as! SingleUnit
            if unit.character == Character.DEMIGOD {
                demigods.append(unit)
            }
        }
        
        let lastPos = unitGroup.position

        owner.removeUnit(unit: unitGroup)
        EventDispatcher.publish("SetTileType", ("pos",Point2D(unitGroup.position)), ("type", Tile.types.vacant), ("perma", false))
        EventDispatcher.publish("RemoveUnit", ("unit", unitGroup))
        
        owner._followers += units - demigods.count
        
        if (demigods.count > 0) {
            // Make a new unit with whatever demigods we shouldn't return
            let demigodUnitGroup = GameObject()
            demigodUnitGroup.addComponent(type: UnitGroupComponent.self)
            let game = unitGroup.gameObject.game
            game!.addGameObject(gameObject: demigodUnitGroup)
            
            let iugc = demigodUnitGroup.getComponent(type: UnitGroupComponent.self)
            iugc?.setOwner(owner)
            iugc?.unitGroup.peopleArray.removeAllObjects()
            for demigod in demigods {
                demigod.modelInstance = nil
                iugc?.unitGroup.peopleArray.add(demigod)
            }
            iugc?.updateModels()
            iugc?.setPosition(lastPos[0], lastPos[1], true)
            owner.addUnit(unit: iugc!)
            EventDispatcher.publish("AddUnit", ("unit", iugc))
        }
    }
    
    public func dispatchUnitGroup(size: Int) {
        let units = min(size, owner._followers)
        if (units > 0) {
            let shuffled = shuffleVacantTiles(tile!.getNeighbours())
            if(shuffled.count > 0) {
                let place = shuffled[Int(arc4random_uniform(UInt32(shuffled.count)))]
                let coord = place.getAxial()
                
                let unitGroup = GameObject()
                unitGroup.addComponent(type: UnitGroupComponent.self)
                owner.game?.addGameObject(gameObject: unitGroup)
                
                let unitGroupComponent = unitGroup.getComponent(type: UnitGroupComponent.self)!
                unitGroupComponent.setPosition(pos.x, pos.y, false)
                unitGroupComponent.move(coord.x, coord.y)
                unitGroupComponent.setOwner(owner)
                
                for _ in 0..<units {
                    let singleUnit = SingleUnit.init()
                    singleUnit.character = Character.PEOPLE
                    unitGroupComponent.unitGroup.peopleArray.add(singleUnit)
                }
                
                unitGroupComponent.updateModels()
                
                owner.addUnit(unit: unitGroupComponent)
                owner._followers -= units
                
                EventDispatcher.publish("AddUnit", ("unit", unitGroupComponent))
                
                print(String(units) + " units deployed to field")
            } else {
                print("No vacant tiles around your city!")
            }
        } else {
            print("No more followers left in base!")
        }
    }
    
    private func shuffleVacantTiles(_ tiles: [Tile]) -> [Tile] {
        var original : [Tile] = tiles
        var shuffled = [Tile]()
        while(original.count > 0) {
            let index = Int(arc4random_uniform(UInt32(original.count)))
            if(original[index].type == Tile.types.vacant) {
                shuffled.append(original[index])
            }
            original.remove(at: index)
        }
        return shuffled
    }
}

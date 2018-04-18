//
//  AIController.swift
//  FingerGod
//
//  Created by Matthew Taylor on 2018-04-14.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation

public class AIController : GameObject {
    private var AIPlayers: [AIPlayer]
    private var map: MapComponent
    
    public init(map: MapComponent) {
        AIPlayers = [AIPlayer]()
        self.map = map
        super.init()
    }
    
    public func setup(numEnemies: Int) {
        for var i in 1...numEnemies {
            var start = map.getRandomTile()
            while(start.getType() != Tile.types.vacant) {
                start = map.getRandomTile()
            }
            let player = AIPlayer(start.getAxial(), map: map)
            game!.addGameObject(gameObject: player)
            
            AIPlayers.append(player)
            
            if (i == 1) {
                let undineUnitGroup = GameObject()
                undineUnitGroup.addComponent(type: UnitGroupComponent.self)
                game!.addGameObject(gameObject: undineUnitGroup)
                
                let iugc = undineUnitGroup.getComponent(type: UnitGroupComponent.self)
                iugc?.setOwner(player)
                iugc?.unitGroup.peopleArray.removeAllObjects()
                let undine = Undine()
                undine.power = player.addPowerByName(undine.powerName)
                iugc?.unitGroup.peopleArray.add(undine)
                iugc?.updateModels()
                let pos = start.getNeighbours()[0]
                iugc?.setPosition(pos.getAxial().x, pos.getAxial().y, true)
                player.addUnit(unit: iugc!)
                EventDispatcher.publish("AddUnit", ("unit", iugc))
            }
            else if (i == 2) {
                let onyxraUnitGroup = GameObject()
                onyxraUnitGroup.addComponent(type: UnitGroupComponent.self)
                game!.addGameObject(gameObject: onyxraUnitGroup)
                
                let iugc = onyxraUnitGroup.getComponent(type: UnitGroupComponent.self)
                iugc?.setOwner(player)
                iugc?.unitGroup.peopleArray.removeAllObjects()
                let onyxra = Onyxra()
                onyxra.power = player.addPowerByName(onyxra.powerName)
                iugc?.unitGroup.peopleArray.add(onyxra)
                iugc?.updateModels()
                let pos = start.getNeighbours()[0]
                iugc?.setPosition(pos.getAxial().x, pos.getAxial().y, true)
                player.addUnit(unit: iugc!)
                EventDispatcher.publish("AddUnit", ("unit", iugc))
            }
            
            player._city!.interact()
        }
    }
    
    private func takeEnemyTurn() {
        
    }
}

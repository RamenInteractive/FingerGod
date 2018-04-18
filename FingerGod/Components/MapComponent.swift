//
//  MapComponent.swift
//  FingerGod
//
//  Created by Aaron F on 2018-02-28.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import UIKit
import GLKit

public class MapComponent : Component, Subscriber {
    
    public var tileMap : TileMap!
    
    public var size = 13
    
    open override func create() {
        tileMap = TileMap(size,1)
        
        EventDispatcher.subscribe("AddStructure", self)
        EventDispatcher.subscribe("SetTileColor", self)
        EventDispatcher.subscribe("SetTileType", self)
        EventDispatcher.subscribe("ResetTileType", self)
        
        EventDispatcher.subscribe("BattleEnd",self)
    }
    
    public func getClosest(_ coord: GLKVector3) -> Point2D {
        var shortest = Float.greatestFiniteMagnitude
        var select: Point2D!
        
        for (point, tile ) in tileMap.getTiles() {
            let tileCoord = GLKVector3Make(tile.worldCoordinate.0, 0, tile.worldCoordinate.1)
            let dist = GLKVector3Distance(tileCoord, coord)
            if dist < shortest {
                shortest = dist
                select = point
            }
        }
        
        return select
    }
    
    public func getRandomTile() -> Tile {
        var tile : Tile? = nil
        
        while (tile == nil) {
            let q = Int(arc4random_uniform(UInt32(tileMap.mapWidth))) - tileMap.mapWidth / 2
            let r = Int(arc4random_uniform(UInt32(tileMap.mapHeight))) - tileMap.mapHeight / 2
            tile = tileMap.getTile(Point2D(q,r))
        }
        
        return tile!
    }
    
    public func setTileColor(tile: Point2D, color: [Float]) {
        tileMap.getTile(tile)!.model.color = color
    }
    
    public func resetTileColor(tile: Point2D){
        tileMap.getTile(tile)!.resetColor()
    }
    
    public func getTile(pos: Point2D) -> Tile? {
        return tileMap.getTile(pos)
    }
    
    func notify(_ eventName: String, _ params: [String : Any]) {
        switch(eventName) {
        case "AddStructure":
            let str = params["structure"]! as! Structure
            let pos = params["coords"]! as! Point2D
            tileMap.getTile(pos)?.addStructure(str)
            print("Added Structure: " + String(pos.x) + ", " + String(pos.y))
            break
            
        case "SetTileColor":
            let pos = params["pos"]! as! Point2D
            let color = params["color"] as? [Float]
            
            if(color != nil) {
                setTileColor(tile: pos, color: color!)
            } else {
                resetTileColor(tile: pos)
            }
            break
        
        case "SetTileType":
            let pos = params["pos"]! as! Point2D
            let type = params["type"]! as! Tile.types
            let perma = params["perma"]! as! Bool
            
            tileMap.getTile(pos)!.setType(type, perma)
            break
            
        case "ResetTileType":
            let pos = params["pos"]! as! Point2D
            let tile = tileMap.getTile(pos)!
            tile.setType(tile.originalType, false)
            tile.resetColor()
            break
            
        default:
            break
        }
    }
    
    public override func update(delta: Float) {
        super.update(delta: delta)
        
        /*followerLabel.text = String(player._followers)
        goldLabel.text = String(player._gold)
        manaLabel.text = String(player._mana)*/
    }
    
    /*public func generate() {
        let testEnemy = GameObject()
        testEnemy.addComponent(type: UnitGroupComponent.self)
        
        self.gameObject.game!.addGameObject(gameObject: testEnemy)
        let ugComp = testEnemy.getComponent(type: UnitGroupComponent.self)
        ugComp?.move(3, 3)
        ugComp?.setAlignment(Alignment.ENEMY)
        
        // Make the enemy group a little beefier
        for _ in 0 ... 10 {
            ugComp?.unitGroup.peopleArray.add(SingleUnit())
        }
        
        EventDispatcher.publish("AddUnit", ("unit", ugComp!))
    }*/
}

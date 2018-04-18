//
//  InputManager.swift
//  FingerGod
//
//  Created by Matt on 2018-04-13.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import GLKit

public class InputManager : Subscriber {
    private let SELECTION_COLOR: [Float] = [0, 0.95, 1.0, 1.0]
    public let player: PlayerObject
    private let map: MapComponent
    private var unitGroupManager : UnitGroupManager
    
    private var selected: Point2D?
    private var powerMenuEnabled : Bool
    private var powerMenu : [RoundButton]
    
    public init(player: PlayerObject, map: MapComponent, unitGroupManager: UnitGroupManager) {
        self.player = player
        self.map = map
        self.unitGroupManager = unitGroupManager
        powerMenuEnabled = false
        powerMenu = [RoundButton]()
    }
    
    
    /// TapScreen
    ///
    /// Functioned called when tapping on the screen to select appropriate tiles through raycasting
    ///
    /// - Parameter coord: the Point that describes where on the screen the screen was tapped
    public func tapScreen(coord: CGPoint) {
        let ray = getDirection(coord)
        let location = Renderer.camera.location
        let t = -location.y / ray.y
        let point = GLKVector3Add(location, GLKVector3MultiplyScalar(ray, t))
        let tile = map.getClosest(point)
        selectTile(tile.x, tile.y)
    }
    
    
    /// Toggles the GodPower menu
    public func togglePowerMenu() {
        powerMenuEnabled = !powerMenuEnabled
        
        if (powerMenuEnabled) {
            var pos : Int
            pos = 0
            for power in player.powers {
                pos += 50
                EventDispatcher.publish("AddPowerButton", ("button", power._btn!), ("pos", pos))
            }
        } else {
            for power in player.powers {
                player._curPower = nil
                power._btn?.removeFromSuperview()
            }
        }
    }
    
    func notify(_ eventName: String, _ params: [String : Any]) {
        switch(eventName) {
        default:
            break
        }
    }
    
    
    /// SelectTile
    ///
    /// Called when selecting a tile on the map to execute appropriate action
    ///
    /// - Parameters:
    ///   - q: the column axial coordinate of the selected tile
    ///   - r: the row axial coordinate of the selected tile
    private func selectTile(_ q: Int, _ r: Int) {
        var nextObject : UnitGroupComponent? = nil
        var prevObject : UnitGroupComponent? = nil
        
        var noSelect = false
        
        if(selected != nil) {
            map.resetTileColor(tile: selected!)
            print("Selected position: " + String(describing: selected?.x) + "," + String(describing: selected?.y))
            for c in unitGroupManager.unitGroups {
                 if c.position[0] == selected?.x && c.position[1] == selected?.y {
                     prevObject = c
                 }
                 if c.position[0] == q && c.position[1] == r {
                     nextObject = c
                 }
             }
        }
        
        let selectedTile = map.getTile(pos: Point2D(q,r))!
        
        // DEBUG STATEMENTS
        var output = "\n"
        output += "Selected Tile (" + String(selectedTile.getAxial().x) + ", " + String(selectedTile.getAxial().y) + ") ["
        output += "Type: " + String(describing: selectedTile.type) + ", "
        output += "World Coord: (" + String(selectedTile.worldCoordinate.x) + ", " + String(selectedTile.worldCoordinate.y) + ")"
        output += "]"
        output += "\n"
        print(output)
        
        if (player._curPower != nil) {
            noSelect = true
                var power : Power?
                switch (player._curPower!.Label) {
                case "Fire":
                    power = FirePower(player: player)
                    break
                    
                case "Water":
                    power = WaterPower(player: player)
                    break
                    
                case "Earth":
                    power = EarthPower(player: player)
                    break
                    
                default:
                    break
                }
            
            if (player._mana >= power!._cost){
                player.game!.addGameObject(gameObject: power!)
                power?.activate(tile: selectedTile)
                player._curPower = nil
            }
        } else {
        
            switch(selectedTile.type) {
            case Tile.types.structure:
                if (prevObject != nil && prevObject!.owner!.id == player.id!) {
                    let curTile = map.getTile(pos: Point2D(prevObject!.position))!
                    if(PathFinder.distance(curTile, selectedTile) < 2.0) {
                        (selectedTile.getStructure()! as! City).returnUnits(prevObject!)
                    } else {
                        let neighbours = selectedTile.getNeighbours()
                        var shortest = Float.greatestFiniteMagnitude
                        var closest: Tile = neighbours[0]
                        for tile in neighbours {
                            let dist = PathFinder.distance(curTile, tile)
                            if(dist < shortest) {
                                shortest = dist
                                closest = tile
                            }
                        }
                        prevObject!.setTarget(TilePathFindingTarget(tile: closest, map: map.tileMap))
                    }
                } else {
                    selectedTile.getStructure()!.interact()
                }
                noSelect = true
                break
            
            case Tile.types.vacant:
                if (prevObject != nil) {
                    if (nextObject == nil && prevObject!.owner!.id == player.id!) {
                        print("Moving unit...")
                        prevObject!.setTarget(TilePathFindingTarget(tile: selectedTile, map: map.tileMap))
                        noSelect = true
                    }
                }
                break
                
                case Tile.types.occupied:
                    if (nextObject != nil) {
                        if(nextObject!.owner!.id == player.id! && nextObject === prevObject) {
                            print("Ally Double Selected")
                            // TODO: display unit stuff
                            let peopleNum = nextObject?.unitGroup.peopleArray.count
                            print("Units in tile "  + String(describing: peopleNum))
                            EventDispatcher.publish("AllyClick", ("unitCount", nextObject),  ("tile", selectedTile))
                            noSelect = true
                        } else if (nextObject!.owner!.id != player.id!) {
                            print("Enemy Selected")
                            // Note: Battle doesn't start here, we simply move to the tile
                            // But in future, may want to have the player start moving to the "enemy" rather than its tile
                            if (prevObject != nil) {
                                prevObject!.setTarget(EnemyPathFindingTarget(enemy: nextObject!, map: map.tileMap))
                            }
                            noSelect = true
                        } else {
                            // Note: Battle doesn't start here, we simply move to the tile
                            // But in future, may want to have the player start moving to the "enemy" rather than its tile
                            if (prevObject != nil) {
                                print("Ally Selected to Merge")
                                prevObject!.setTarget(MergingPathFindingTarget(ally: nextObject!, map: map.tileMap))
                                noSelect = true
                            }
                            else {
                                print("Ally Selected")
                            }
                        }
                }
                
                default:
                    break
            }
        }
        
        if(!noSelect) {
            selected = Point2D(q,r)
            print(selected)
            map.setTileColor(tile: selected!, color: SELECTION_COLOR)
        } else {
            selected = nil
        }
    }
    
    
    /// GetDirection
    
    /// A function to get a normalized vector representing the direction of the normal of the camera
    ///
    /// - Parameter loc: point on the viewport that the ray originates from
    /// - Returns: the normal to the camera viewport
    private func getDirection(_ loc: CGPoint) -> GLKVector3{
        let bounds = UIScreen.main.bounds
        let x = Float((2 * loc.x) / bounds.size.width - 1.0)
        let y = Float(1.0 - (2 * loc.y) / bounds.size.height)
        let rayClip = GLKVector4Make(x, y, -1.0, 1.0)
        let invPerspective = GLKMatrix4Invert(Renderer.perspectiveMatrix, nil)
        var rayEye = GLKMatrix4MultiplyVector4(invPerspective, rayClip)
        rayEye.z = -1.0
        rayEye.a = 0
        let rayWorld = GLKMatrix4MultiplyVector4(Renderer.camera.transform, rayEye)
        let rayWNorm = GLKVector3Normalize(GLKVector3Make(rayWorld.x, rayWorld.y, rayWorld.z))
        return rayWNorm
    }
}

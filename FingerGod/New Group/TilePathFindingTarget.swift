//
//  TilePathFindingTarget.swift
//  FingerGod
//
//  Created by Aaron F on 2018-04-16.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation

class TilePathFindingTarget : PathFindingTarget {
    private var tile : Tile
    private var map : TileMap
    public init(tile : Tile, map : TileMap) {
        self.tile = tile
        self.map = map
    }
    // Finds the path step-by-step to the target
    func getPathToTarget(from: Point2D) -> [Point2D] {
        return PathFinder.getPath(start: from, end: tile.getAxial(), map: map)
    }
    
    // Did the target change locations since this function was last called (or since the object was created)?
    func changedLocation() -> Bool {
        // A tile cannot move, so the target will never have moved since this function was last called
        return false
    }
    
    // Did we do what we were supposed to do?
    func fulfilled(by: UnitGroupComponent) -> Bool {
        return Point2D(by.position) == tile.getAxial()
    }
}

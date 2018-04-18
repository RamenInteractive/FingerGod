//
//  MergingPathFindingTarget.swift
//  FingerGod
//
//  Created by Aaron F on 2018-04-18.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation

class MergingPathFindingTarget : PathFindingTarget {
    private var ally : UnitGroupComponent
    private var map : TileMap
    private var lastAllyPosition : Point2D
    public init(ally : UnitGroupComponent, map : TileMap) {
        self.ally = ally
        self.map = map
        lastAllyPosition = Point2D(ally.position)
    }
    // Finds the path step-by-step to the target
    func getPathToTarget(from: Point2D) -> [Point2D] {
        return PathFinder.getPath(start: from, end: Point2D(ally.position), map: map)
    }
    
    // Did the target change locations since this function was last called (or since the object was created)?
    func changedLocation() -> Bool {
        let posChanged = lastAllyPosition != Point2D(ally.position)
        lastAllyPosition = Point2D(ally.position)
        return posChanged
    }
    
    // Did we do what we were supposed to do?
    func fulfilled(by: UnitGroupComponent) -> Bool {
        // Do we still exist?
        return by.unitGroup.peopleArray.count == 0
    }
}

//
//  EnemyTilePathFindingTarget.swift
//  FingerGod
//
//  Created by Aaron F on 2018-04-16.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation

class EnemyPathFindingTarget : PathFindingTarget {
    private var enemy : UnitGroupComponent
    private var map : TileMap
    private var lastEnemyPosition : Point2D
    public init(enemy : UnitGroupComponent, map : TileMap) {
        self.enemy = enemy
        self.map = map
        lastEnemyPosition = Point2D(enemy.position)
    }
    // Finds the path step-by-step to the target
    func getPathToTarget(from: Point2D) -> [Point2D] {
        return PathFinder.getPath(start: from, end: Point2D(enemy.position), map: map)
    }
    
    // Did the target change locations since this function was last called (or since the object was created)?
    func changedLocation() -> Bool {
        let posChanged = lastEnemyPosition != Point2D(enemy.position)
        lastEnemyPosition = Point2D(enemy.position)
        return posChanged
    }
    
    // Did we do what we were supposed to do?
    func fulfilled(by: UnitGroupComponent) -> Bool {
        // Is the enemy dead?
        return enemy.unitGroup.peopleArray.count == 0
    }
}

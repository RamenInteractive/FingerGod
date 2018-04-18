//
//  PathFinder.swift
//  FingerGod
//
//  Created by Aaron F on 2018-04-13.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation

public class PathFinder {
    public static func getPath(start:Point2D, end:Point2D, map: TileMap) -> [Point2D] {
        // Begin A* Pathfinding Code
        // Adapted from http://www.redblobgames.com/pathfinding/a-star/introduction.html
        let frontier = PriorityQueue<Tile>()
        var from = [Point2D : Point2D]() // Which point did from[point] come from? Note: Key is Point2D since it's hashable
        var cost = [Point2D : Float]() // What did it cost to get to tile? Note: Key is Point2D since it's hashable
        let endTile = map.getTile(end.x, end.y)
        
        if (endTile == nil) {
            return []
        }
        
        cost[start] = 0
        frontier.add(item: map.getTile(start)!, priority: cost[start]!)
        
        while frontier.count > 0 {
            let curr = frontier.shift()
            
            if (curr.getAxial().x == end.x && curr.getAxial().y == end.y) {
                break
            }
            
            let neighbours = getNeighbours(t: curr, map: map)
            
            for next in neighbours {
                if canNavigate(next.type) {
                    let newCost = cost[curr.getAxial()]! + getCost(next)
                    let nextCost = cost[next.getAxial()]
                    
                    if nextCost == nil || newCost < nextCost! {
                        cost[next.getAxial()] = newCost
                        frontier.add(item: next, priority: newCost + distance(endTile!, next))
                        from[next.getAxial()] = curr.getAxial()
                    }
                }
            }
        }
        
        var path = [end]
        
        // Backtracking to figure out path
        
        var step = end
        // As long as we can keep going back
        while from[step] != nil {
            // Move back and add the previous spot to the list
            step = from[step]!
            path.append(step)
        }
        
        // If the last point isn't the start, then obviously we couldn't get to the end
        // So return an empty array
        
        if (path.last != start) {
            return []
        }
        
        return path.reversed()
    }
    
    public static func getNeighbours(t: Tile, map: TileMap) -> [Tile] {
        /*let pos = t.getAxial()
        var neighbours : [Tile] = []
        for offset in [Point2D(-1, 0), Point2D(-1, 1), Point2D(0, 1), Point2D(1, 0), Point2D(1, -1), Point2D(0, -1)] {
            if let t = map.getTile(Point2D(pos.x + offset.x, pos.y + offset.y)) {
                neighbours.append(t)
            }
        }*/
        return t.getNeighbours()
    }
    
    public static func getCost(_ tile: Tile) -> Float {
        return 1
    }
    
    public static func distance(_ tileA: Tile, _ tileB: Tile) -> Float {
        let ca = tileA.worldCoordinate;
        let cb = tileB.worldCoordinate;
        let c = (x: ca.x - cb.x, y: ca.y - cb.y)
        return (c.x * c.x + c.y * c.y).squareRoot()
    }
    
    private static func canNavigate(_ type : Tile.types) -> Bool {
        return type != Tile.types.boundary && type != Tile.types.structure
    }
}

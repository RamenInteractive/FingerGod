//
//  TileMap.swift
//  FingerGod
//
//  Created by Niko Lauron on 2018-02-24.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation

//Allows the passing of an x and y coordinate
public struct Point2D: Hashable{
    var x : Int
    var y : Int
    
    public init(_ x:Int, _ y:Int) {
        self.x = x
        self.y = y
    }
    
    public init(_ point: [Int]) {
        self.x = point[0]
        self.y = point[1]
    }
    
    public var hashValue: Int {
        return "(\(x),\(y))".hashValue
    }
    
    public static func + (lhs: Point2D, rhs: Point2D) -> Point2D {
        return Point2D(lhs.x + rhs.x, lhs.y + rhs.y)
    }
    
    public static func - (lhs: Point2D, rhs: Point2D) -> Point2D {
        return Point2D(lhs.x - rhs.x, lhs.y - rhs.y)
    }
    
    public static func == (lhs: Point2D, rhs: Point2D) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    public static func * (lhs: Point2D, rhs: Int) -> Point2D {
        return Point2D(lhs.x * rhs, lhs.y * rhs)
    }
    
    public static func / (lhs: Point2D, rhs: Int) -> Point2D {
        return Point2D(lhs.x / rhs, lhs.y / rhs)
    }
}

public class TileMap {
    //Stores the tiles in a 2d coordinate
    private var tileMap = [Point2D:Tile]()
    //Amount of columns in the map
    public var mapWidth : Int
    //Amount of rows in the map
    public var mapHeight : Int
    //Size of the tile
    public var radius :Int
    
    /*
     Initialize the map with a rhombus shape
    */
    public init(_ mapWidth:Int,_ mapHeight:Int,_ radius:Int) {
        self.mapWidth = mapWidth
        self.mapHeight = mapHeight
        self.radius = radius
        
        for i in 0 ..< mapHeight {
            for j in 0 ..< mapWidth {
                tileMap[Point2D(i, j)] = Tile(self, i, j, radius)
            }
        }
    }
    
    
    /// Initialize map with a hexagon shape
    ///
    /// - Parameters:
    ///   - mapRadius: Radius of map
    ///   - tileRadius: Radius size for each hex tile
    public init(_ mapRadius:Int, _ tileRadius: Int) {
        self.mapWidth = mapRadius * 2 + 1
        self.mapHeight = mapRadius * 2 + 1
        self.radius = tileRadius
        
        let start = Point2D(0,0)
        tileMap[start] = Tile(self, start, tileRadius)
        
        if(radius > 0) {
            for r in 1...mapRadius {
                var point = HexDirections.InDirection(start, HexDirection.North,r)
                var dir = HexDirection.SouthEast
                for _ in 0..<HexDirections.Count {
                    for _ in 0..<r {
                        tileMap[point] = Tile(self, point, tileRadius)
                        point = HexDirections.InDirection(point, dir)
                    }
                    dir = HexDirections.NextDirection(dir)
                }
            }
        }
    }
    
    /*
     Get the number of columns
    */
    public func getWidth() -> Int {
        return self.mapWidth
    }
    
    /*
     Set the amount of columns
    */
    public func setWidth(_ newWidth:Int) {
        self.mapWidth = newWidth
    }
    
    /*
     Get the amount of rows
    */
    public func getHeight() -> Int {
        return self.mapHeight
    }
    
    /*
     Set the amount of rows
    */
    public func setHeight(_ newHeight:Int) {
        self.mapHeight = newHeight
    }
    
    public func getTile(_ q: Int, _ r: Int) -> Tile? {
        return self.tileMap[Point2D(q, r)]
    }
    
    public func getTile(_ point: Point2D) -> Tile? {
        return self.tileMap[point]
    }
    
    /*
     Get the map
    */
    public func getTiles() -> [Point2D:Tile]{
        return self.tileMap
    }
}
 

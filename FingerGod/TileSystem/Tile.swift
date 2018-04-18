//
//  Tile.swift
//  FingerGod
//
//  Created by Niko Lauron on 2018-02-24.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import GLKit

/*
 Tile Class for the tiles that make up the map
 */
public class Tile {
    
    //Types of tiles
    public enum types : String {
        case vacant
        case occupied
        case boundary
        case structure
    }
    
    //Tile Dimensions
    public let radius : Int
    public let height : Int
    public let width : Int
    
    public var model : ModelInstance
    public var defaultColor : [GLfloat]
    
    private var structure : Structure?
    
    private let map: TileMap
    
    // Axial Coordinates
    private var q : Int
    
    private var r : Int
    
    public var worldCoordinate: (x: Float, y: Float) {
        get {
            return axialToWorld(q, r)
        }
    }
    
    //Type of Tile
    public var type : types
    public var originalType : types
    
    /*
     Initialize a tile using a radius and single coord
     */
    public convenience init(_ map: TileMap, _ coordinate: Point2D, _ radius:Int) {
        self.init(map, coordinate.x, coordinate.y, radius, types.vacant)
    }
    
    public convenience init(_ map: TileMap, _ coordinate: Point2D, _ radius: Int, _ type: types) {
        self.init(map, coordinate.x, coordinate.y, radius, type)
    }
    
    public convenience init(_ map: TileMap, _ coordinate: Point2D, _ radius: Int, _ str: Structure) {
        self.init(map, coordinate, radius, types.structure)
        structure = str
    }
    
    public convenience init(_ map: TileMap, _ q: Int, _ r: Int, _ radius: Int) {
        self.init(map, q, r, radius, types.vacant)
    }
    
    /*
     Initialize a tile using a radius (q,r) split
     */
    public init(_ map: TileMap, _ q: Int, _ r: Int, _ radius:Int, _ type: types) {
        self.radius = radius
        
        width = radius * 2
        height = radius * (Int(sqrt(3)))
        
        self.type = type
        self.originalType = type
        
        self.q = q
        self.r = r
        
        self.map = map
        
        var hex : Model?
        
        do {
            hex = try ModelReader.read(objPath: "HexTileWithTex2")
            hex!.texture = ImageReader.read(name: "HexTile.png")
        } catch {
            print("There was a problem initializing this tile model: \(error)")
        }
        
        let x = 3.0 / 2.0 * Float(q) // x value
        let z = Float(3).squareRoot() * (Float(r) + Float(q) / 2) // z value
        
        //defaultColor = [0.075, Float(0.85 + (q % 2 == 0 ? 0 : 0.15)), 0.25 + Float(r % 2 == 0 ? 0 : 0.15), 1.0]
        defaultColor = [1.0, 1.0, 1.0, 1.0]
        
        model = ModelInstance(model: hex!)
        model.color = defaultColor
        model.transform = GLKMatrix4Translate(model.transform, x, 0, z)
        model.transform = GLKMatrix4RotateX(model.transform, Float.pi/2)
        
        Renderer.addInstance(inst: model)
    }

    /*
     Get the type of the tile
    */
    public func getType() -> types {
        return self.type
    }
    
    /*
     Set the type of the tile
    */
    public func setType(_ newType:types, _ perma: Bool) {
        self.type = newType
        if(type == Tile.types.boundary) {
            model.color = [0.4, 0.286, 0, 1.0]
        } else {
            model.color = [1.0, 1.0, 1.0, 1.0]
        }
        if(perma) {
            self.originalType = newType
            self.defaultColor = model.color
        }
    }
    
    public func setAxial(_ coord: Point2D) {
        q = coord.x
        r = coord.y
    }
    
    public func getAxial() -> Point2D {
        return Point2D(q,r)
    }
    
    public func resetColor() {
        model.color = defaultColor
    }
    
    public func addStructure(_ structure: Structure) {
        self.structure = structure
        type = types.structure
        originalType = types.structure
        structure.model.transform = GLKMatrix4Translate(structure.model.transform, worldCoordinate.x, 0.05, worldCoordinate.y)
        structure.tile = self
    }
    
    public func getStructure() -> Structure? {
        return self.structure
    }
    
    public func getNeighbours() -> [Tile] {
        var neighbours = [Tile]()
        let point = Point2D(q,r)
        var pos = HexDirections.InDirection(point, HexDirection.North)
        let start = map.getTile(pos)
        if (start != nil) {
            neighbours.append(start!)
        }
        var dir = HexDirection.SouthEast
        for _ in 1..<HexDirections.Count {
            pos = HexDirections.InDirection(pos, dir)
            let tile = map.getTile(pos)
            if(tile != nil) {
                neighbours.append(tile!)
            }
            dir = HexDirections.NextDirection(dir)
        }
        return neighbours
    }
    
    private func axialToWorld(_ q: Int, _ r: Int) -> (x: Float, y: Float) {
        let x = 3.0 / 2.0 * Float(q) // x value
        let z = Float(3).squareRoot() * (Float(r) + Float(q) / 2) // z value
        
        return (x,z)
    }
}


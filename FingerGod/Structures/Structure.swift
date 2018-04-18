//
//  Structure.swift
//  FingerGod
//
//  Created by Matthew Taylor on 2018-03-28.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation

public class Structure {
    public var model : ModelInstance
    public let pos : Point2D
    public var tile : Tile?
    public var hp : Int
    
    public init(_ pos: Point2D, _ mi: ModelInstance) {
        self.pos = pos
        self.model = mi
        self.hp = 10
        EventDispatcher.publish("AddStructure", ("structure",self), ("coords",pos))
    }
    
    public func interact() {}
}

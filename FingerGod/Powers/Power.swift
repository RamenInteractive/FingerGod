//
//  Power.swift
//  FingerGod
//
//  Created by Niko Lauron on 2018-03-27.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation

public class Power : GameObject{
    
    public var _player : PlayerObject
    public var _time : Float
    public var _tick : Float
    public var _count : Int
    public var _duration : Int
    public var _damage : Float
    public var _cost : Float
    public var _active : Bool
    public var unitGroupManager : UnitGroupManager?
    public var _btn : RoundButton?
    public var Label: String
    
    public init(player: PlayerObject) {
        _player = player
        _time = 0.0
        _tick = 1.0
        _count = 0
        _active = false
        _duration = 0
        _damage = 0
        _cost = 0.0
        Label = "Off"
        super.init()
    }
    
    public func activate(tile : Tile) {
        
    }
    
    public override func update(delta: Float) {
        
    }
    
}

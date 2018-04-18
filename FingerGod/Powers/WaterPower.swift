//
//  WaterPower.swift
//  FingerGod
//
//  Created by Niko Lauron on 2018-04-13.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import UIKit

public class WaterPower : Power {
    
    public var target : Tile?
    
    public override init(player: PlayerObject) {
        super.init(player: player)
        
        Label = "Water"
        
        _duration = 5
        _damage = 5.0
        _cost = 25.0
        
        _btn = RoundButton.init()
        _btn?.setTitle("Water", for: .normal)
        _btn?.setTitleColor(UIColor.black, for: .normal)
        _btn?.cornerRadius = 25
        _btn?.borderWidth = 1
        _btn?.borderColor = UIColor.blue
        _btn?.addTarget(self, action: #selector(waterTap), for: UIControlEvents.touchUpInside)
    }
    
    @objc func waterTap() {
        if (_player._mana >= _cost) {
            _player._curPower = self
        }
    }
    
    public override func activate(tile : Tile){
        super.activate(tile: tile)
        _player._mana -= _cost
        target = tile
        tile.model.color = [0.0, 0.0, 1.0, 1.0]
        _count = 0
        _time = 0.0
        _active = true
    }
    
    public override func update(delta: Float) {
        if (_active) {
            _time += delta
            
            if (_time >= _tick) {
                EventDispatcher.publish("HealUnit", ("tile", target!), ("heal", _damage), ("owner", _player.id))
                _time = 0.0
                _count += 1
            }
            
            if (_count >= _duration) {
                target?.resetColor()
                _active = false
            }
        }
    }
}


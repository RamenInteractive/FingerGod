//
//  FirePower.swift
//  FingerGod
//
//  Created by Niko Lauron on 2018-04-13.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import UIKit

public class FirePower : Power {
    
    public var target : Tile?
    
    public override init(player: PlayerObject) {
        super.init(player: player)
        
        Label = "Fire"
        
        _duration = 20
        _damage = 3.0
        _cost = 50
        
        _btn = RoundButton.init()
        _btn?.setTitle("Fire", for: .normal)
        _btn?.setTitleColor(UIColor.black, for: .normal)
        _btn?.cornerRadius = 25
        _btn?.borderWidth = 1
        _btn?.borderColor = UIColor.red
        _btn?.addTarget(self, action: #selector(fireTap), for: UIControlEvents.touchUpInside)
    }
    
    @objc func fireTap() {
        if (_player._mana >= _cost) {
            _player._curPower = self
        }
    }
    
    public override func activate(tile : Tile){
        super.activate(tile: tile)
        _player._mana -= _cost
        target = tile
        tile.model.color = [1.0, 0.411, 0.706, 1.0]
        _count = 0
        _time = 0.0
        _active = true
    }
    
    public override func update(delta: Float) {
        if (_active) {
            _time += delta
            
            if (_time >= _tick) {
                EventDispatcher.publish("DamageUnit", ("tile", target!), ("damage", _damage), ("owner", _player.id))
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

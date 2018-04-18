//
//  EarthPower.swift
//  FingerGod
//
//  Created by Niko Lauron on 2018-04-13.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import UIKit

public class EarthPower : Power {
    
    public override init(player: PlayerObject) {
        super.init(player: player)
        
        Label = "Earth"
        _cost = 10.0
        
        _btn = RoundButton.init()
        _btn?.setTitle("Earth", for: .normal)
        _btn?.setTitleColor(UIColor.black, for: .normal)
        _btn?.cornerRadius = 25
        _btn?.borderWidth = 1
        _btn?.borderColor = UIColor.yellow
        _btn?.addTarget(self, action: #selector(earthTap), for: UIControlEvents.touchUpInside)
    }
    
    @objc func earthTap() {
        if (_player._mana > _cost) {
            _player._curPower = self
        }
    }
    
    public override func activate(tile : Tile) {
        super.activate(tile: tile)
        _player._mana -= _cost
        if(tile.getType() == Tile.types.boundary) {
            EventDispatcher.publish("SetTileType", ("pos", tile.getAxial()), ("type", Tile.types.vacant), ("perma", true))
        } else if (tile.getType() == Tile.types.vacant){
            EventDispatcher.publish("SetTileType", ("pos", tile.getAxial()), ("type", Tile.types.boundary), ("perma", true))
        }
    }
    
    public override func update(delta: Float) {
        
    }
}

//
//  Demigod.swift
//  FingerGod
//
//  Created by Aaron F on 2018-04-18.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation

class Demigod : SingleUnit {
    var powerName = ""
    var power : Power?
    
    override init() {
        super.init()
        maxHP = 300
        hp = maxHP
        attack = 50
        character = Character.DEMIGOD
    }
    
    public override func getModelName() -> String {
        return "DemiToken"
    }
}

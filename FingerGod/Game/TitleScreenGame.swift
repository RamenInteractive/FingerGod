//
//  TitleScreenGame.swift
//  FingerGod
//
//  Created by Aaron F on 2018-04-18.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

public class TitleScreenGame : Game {
    private var unitGroupManager : UnitGroupManager?
    public override func onGameStart() {
        
        self.timeMultiplier = 2.0
        super.onGameStart()
        
        let map = GameObject()
        map.addComponent(type: MapComponent.self)
        let mapComp = map.getComponent(type: MapComponent.self)
        
        self.addGameObject(gameObject: map)        //player.setupPowers()
        
        PlayerObject.resetStatics()
        unitGroupManager = UnitGroupManager(self, map.getComponent(type: MapComponent.self)!)
        aiControl = AIController(map: map.getComponent(type: MapComponent.self)!)
        self.addGameObject(gameObject: aiControl!)
        aiControl!.setup(numEnemies: 6)
        //map.getComponent(type: MapComponent.self)!.generate()
        
        Renderer.camera.move(x: 0, y: 1.0, z: 12)
        Renderer.camera.rotate(angle: -Float.pi * 1 / 80, x: 1, y: 0, z: 0)
    }
}


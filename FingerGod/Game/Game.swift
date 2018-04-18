//
//  Game.swift
//  FingerGod
//
//  Created by Aaron F on 2018-02-15.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation

/*
 The overall game
 Ties everything together and interfaces it with the ViewController
*/
public class Game {
    // The game objects within the game
    private var gameObjects = [Int : GameObject]()
    // The time of the last update to be called
    private var lastTickTime = mach_absolute_time()
    // The timebase info
    private var timebaseInfo = mach_timebase_info_data_t()
    // ID numbers
    private var idCount = 0
    
    public var timeMultiplier : Double = 1
    
    public var input: InputManager?
    
    public var aiControl: AIController?

    /*
     Initializes the game
     */
    public init() {
        mach_timebase_info(&timebaseInfo)
        onGameStart()
    }
    
    /*
     Adds a GameObject to the game
     When a GameObject is added to the game, all of its create methods are automatically called
     In other words, it assumes the components for the GameObject are all set up already
     
     Returns the ID that was given to the added object
     */
    @discardableResult
    public func addGameObject(gameObject: GameObject) -> Int {
        gameObjects[idCount] = gameObject
        gameObject.id = idCount;
        idCount += 1;
        gameObject.game = self
        gameObject.create()
        
        return gameObject.id!;
    }
    
    /*
     Retrieve a GameObject by its ID
     Returns the GameObject if found, nil if not found
    */
    public func getGameObject(byId: Int) -> GameObject? {
        return gameObjects[byId]
    }
    
    /*
     Removes a GameObject from the game
     */
    public func removeGameObject(gameObject: GameObject) {
        self.removeGameObject(byId: gameObject.id!)
    }
    
    /*
     Removes a GameObject from the game by its id
     */
    public func removeGameObject(byId: Int) {
        let ind = gameObjects.index{$0.value.id == byId}
        if (ind != nil) {
            gameObjects[ind!].value.delete()
            gameObjects[gameObjects[ind!].key] = nil
        }
    }
    
    /*
     Things to be called when the game starts
    */
    
    public func onGameStart() {
    }
    
    /*
     The function that updates all of the game objects
     Runs both early and late updates
     */
    public func update() {
        let currentTickTime = mach_absolute_time()
        let timeDiff = currentTickTime - lastTickTime
        let delta = Double(timeDiff) * Double(timebaseInfo.numer) / Double(timebaseInfo.denom) / 1000000000
        lastTickTime = currentTickTime
        
        // Perform the regular updates
        for o in gameObjects {
            o.value.update(delta: Float(delta * timeMultiplier))
        }
        
        // Perform the late updates
        for o in gameObjects {
            o.value.lateUpdate(delta: Float(delta * timeMultiplier))
        }
    }
}

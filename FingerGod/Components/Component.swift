//
//  Component.swift
//  FingerGod
//
//  Created by Aaron F on 2018-02-15.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation

/*
 A generic component that can be inside of a GameObject to define functionality and/or data.
 */
open class Component {
    /*
     The GameObject that contains this component
     */
    open var gameObject: GameObject {
        get {
            return _gameObject
        }
    }
    private var _gameObject: GameObject
    required public init(gameObject:GameObject) {
        _gameObject = gameObject
    }
    /*
     A hook that allows you to change things when the component is created
     Note: This is not really intended to be used to initialize variables unless they are to be dynamically generated from other variables
     */
    open func create() {
    }
    /*
     A hook that allows things in the component to be updated every game tick
     */
    open func update(delta:Float) {
    }
        
    /*
     A hook that allows things in the componenet to be updated every game tick, similar to update()
     This update is called after all objects' update() functions have been called
     */
    open func lateUpdate(delta:Float) {
        
    }
    
    open func delete() {
        
    }
}

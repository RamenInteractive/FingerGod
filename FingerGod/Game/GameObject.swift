	//
//  GameObject.swift
//  FingerGod
//
//  Created by Aaron F on 2018-02-15.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
/*
 Any object within the game. Its functionality is divided into several components which define different sets of data and functionality for the GameObject.
 */
public class GameObject {
    // The identifier of this object
    public var id: Int? {
        get {
            return _id
        }
        set(newId) {
            _id = newId;
        }
    }
    private var _id: Int? = 0
    
    // The game this GameObject belongs to
    // Temporary
    public var game: Game?
    
    // Whether the object has been properly created or not
    private var created = false
    
    // The components this object contains
    private var components = Array<Component>()
    
    // Initializes the GameObject with an ID
    public init() {
    }
    
    // Adds a component to the GameObject
    @discardableResult
    public func addComponent<T : Component>(type: T.Type) -> Component {
        let component = T.init(gameObject: self)
        components.append(component)
        return component
    }
    
    /*
     Gets a component from the GameObject of the specified type
     Returns nil if the component of that type wasn't found.
     If there are multiple components of the same type in one object, it returns the first one.
     */
    public func getComponent<T: Component>(type: T.Type) -> T? {
        for c in components {
            if let ret = c as? T {
                return ret
            }
        }
        return nil
    }
    
    /*
     Initializes the game objects, initializing all of its individual functions
     This is separate from init() becuase it may need information from other components which may not yet be instantiated
     */
    public func create() {
        created = true
        for c in components {
            c.create()
        }
    }
    
    // Updates the GameObject by updating all of the components within it
    public func update(delta:Float) {
        if (created) {
            for c in components {
                c.update(delta: delta)
            }
        }
    }
    
    // Also updates the GameObject, but is handled after other updates have occurred
    public func lateUpdate(delta:Float) {
        if (created) {
            for c in components {
                c.lateUpdate(delta: delta)
            }
        }
    }
    
    public func delete() {
        for c in components {
            c.delete()
        }
    }
}

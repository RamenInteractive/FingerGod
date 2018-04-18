//
//  ModelInstance.swift
//  FingerGod
//
//  Created by Aaron F on 2018-02-26.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import GLKit

// A single instance of a model.
// Should have one for each "thing" drawn on the screen
// Can share a model with other ModelInstance objects
public class ModelInstance {
    public var model: 	Model
    // The transform that holds the position + rotation of the object
    public var transform = GLKMatrix4Identity
    public var color : [GLfloat] = [1.0, 1.0, 1.0, 1.0]
    
    public init(model: Model) {
        self.model = model
    }
}

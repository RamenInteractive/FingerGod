//
//  RotatingCubeComponent.swift
//  FingerGod
//
//  Created by Aaron F on 2018-02-27.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import GLKit

public class RotatingCubeComponent : Component, Subscriber {
    func notify(_ eventName: String, _ params: [String : Any]) {
        switch (eventName) {
        case "BattleEnd":
            switch (params["result"] as! String) {
            case "tie":
                setColor(newCol: [1.0, 1.0, 0.0, 1.0])
                break
            case "awin":
                setColor(newCol: [1.0, 0.0, 0.0, 1.0])
                break
            case "bwin":
                setColor(newCol: [0.0, 0.0, 1.0, 1.0])
                break
            default:
                break
            }
            break
        default:
            break
        }
    }
    
    private var modelInst : ModelInstance!
    open override func create() {
        do {
            let model = try ModelReader.read(objPath: "CubeModel")
            modelInst = ModelInstance(model: model)
            setColor(newCol: [1.0, 1.0, 1.0, 1.0])
            Renderer.addInstance(inst: modelInst)
            _ = EventDispatcher.subscribe("BattleEnd", self)
        } catch {
            print("There was a problem: \(error)")
        }
    }

    open override func update(delta:Float) {
        modelInst.transform = GLKMatrix4Rotate(modelInst.transform, Float.pi * delta / 2, 0.8, 0.2, 0.0)
    }
    
    open func setColor(newCol: [Float]) {
        modelInst.color = newCol
    }
}

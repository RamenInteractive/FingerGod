//
//  UnitGroupComponent.swift
//  FingerGod
//
//  Created by Aaron F on 2018-03-27.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import GLKit

/**
    A component for a unit group game object which defines its behaviour as a group container
*/
public class UnitGroupComponent : Component {
    // Axial coordinate position
    public var position = [0, 0]
    private var unitModels = [String : Model]()
    
    // Positions for display purposes
    private var startPosition = [0, 0]
    private var endPosition = [0, 0]

    var unitGroup = UnitGroup(peopleNum:0)

    private var squareSize = 0
    
    private var initShape = GLKMatrix4Scale(GLKMatrix4Identity, 0.25, 0.25, 0.25)
    //public var alignment = Alignment.NEUTRAL
    public var owner : PlayerObject?
    
    public var movePath : [Point2D] = []
    private var stepProgress : Float = 0.0
    public var moveSpeed : Float = 1.0 // Tiles per second
    
    public var target : PathFindingTarget?
    
    // Are we stopped by something?
    public var haltCounter = 0
    
    private var lastHealTime : Float = 0
    private var secsToHeal : Float = 1
    
    public override func create() {
        print("Creating Unit Group")
        do {
            updateModels()
        } catch {
            print("There was a problem: \(error)")
        }
    }
    
    public override func update(delta: Float) {
        
        // Heal the unit passively
        lastHealTime += delta
        if (lastHealTime > secsToHeal) {
            lastHealTime -= secsToHeal
            for u in unitGroup.peopleArray {
                let unit = u as! SingleUnit
                unit.heal(1)
            }
        }
        
        // If the unit hasn't moved and they have somewhere they want to move and they can move, then start moving them
        if (stepProgress <= 0.0 && movePath.count > 0 && haltCounter <= 0) {
            // Recalibrate movement
            if target != nil {
                self.movePath = target!.getPathToTarget(from: Point2D(position))
            }
            // Remove any extraneous movement paths
            while (movePath.count > 0 && movePath[0].x == position[0] && movePath[0].y == position[1]) {
                movePath.removeFirst(1)
            }
            
            if (movePath.count > 0) {
                endPosition[0] = movePath[0].x
                endPosition[1] = movePath[0].y
            }
        }
        
        // If we are moving and haven't reached our destination
        if ((endPosition[0] != startPosition[0] || endPosition[1] != startPosition[1]) && haltCounter <= 0) {
            stepProgress += moveSpeed * delta
            if (stepProgress >= 0.5 && (position[0] != endPosition[0] || position[1] != endPosition[1])) {
                position[0] = endPosition[0]
                position[1] = endPosition[1]
                EventDispatcher.publish("UnitMoved", ("newPos", Point2D(position)), ("oldPos", Point2D(startPosition)), ("unit", self))
                
            }
            if (stepProgress >= 1.0) {
                // Reached our destination
                startPosition[0] = endPosition[0]
                startPosition[1] = endPosition[1]
                
                stepProgress = 0.0
                
                if (target != nil && target!.fulfilled(by: self)) {
                    // We did what we set out to do, woo!
                    target = nil
                }
            }
            updateRenderPos()
        }
    }
    
    // Renderer clenaup code when the object is deleted by the game
    public override func delete() {
        for u in unitGroup.peopleArray {
            let unit = u as! SingleUnit
            if (unit.modelInstance != nil) {
                let inst = unit.modelInstance!
                Renderer.removeInstance(inst: inst)
            }
        }
    }

    // Sets the position of the unit without interpolating. May or may not trigger the moving event, depending on triggerMove being true or false
    public func setPosition(_ x : Int, _ y : Int, _ triggerMove : Bool = true) {
        let oldPos = position
        position[0] = x
        position[1] = y
        startPosition[0] = x
        startPosition[1] = y
        endPosition[0] = x
        endPosition[1] = y
        stepProgress = 0
        if (triggerMove) {
            EventDispatcher.publish("UnitMoved", ("newPos", Point2D(position)), ("oldPos", Point2D(oldPos)), ("unit", self))
        }
        
        updateRenderPos()
    }
    
    public func revertPartStep() {
        if (stepProgress < 0.5) {
            stepProgress = 0
            updateRenderPos()
        }
    }
    
    public func move(_ x : Int, _ y : Int) {
        movePath.append(Point2D(x, y))
        updateRenderPos()
    }
    
    public func offset(_ x : Float, _ y : Float, _ z : Float) {
        let tmp = GLKMatrix4Translate(GLKMatrix4Identity, x, y, z)
        initShape = GLKMatrix4Multiply(tmp, initShape)
        updateRenderPos()
    }
    
    // Updates the positions of the individual unit models within the unit group
    private func updateRenderPos() {
        let axs = axialToWorld(startPosition[0], startPosition[1])
        let axe = axialToWorld(endPosition[0], endPosition[1])
        let ax = (x: axs.x  * (1 - stepProgress) + axe.x * stepProgress, y: axs.y  * (1 - stepProgress) + axe.y * stepProgress)

        var num : Int = 0
        for u in unitGroup.peopleArray {
            let unit = u as! SingleUnit
            if (unit.modelInstance != nil) {
                let xOff = (Float(num % squareSize) - Float(squareSize) / 2) * 0.2
                let yOff = (Float(num / squareSize) - Float(squareSize) / 2) * 0.2
                let inst = unit.modelInstance!

                inst.transform = GLKMatrix4Translate(GLKMatrix4Identity, ax.x + xOff, 0.25, ax.y + yOff)
                inst.transform = GLKMatrix4Multiply(inst.transform, initShape)
            }
            num += 1
        }
    }
    
    /*public func setAlignment(_ alignment: Alignment) {
        self.alignment = alignment;
        switch(alignment) {
        case Alignment.NEUTRAL:
            modelInst?.color = [1.0, 1.0, 1.0, 1.0]
            break
        case Alignment.ALLIED:
            modelInst?.color = [0.0, 0.2, 1.0, 1.0]
            break
        case Alignment.ENEMY:
            modelInst?.color = [1.0, 0.2, 0.0, 1.0]
            break
        }
    }*/
    
    public func setOwner(_ player: PlayerObject) {
        owner = player
        for u in unitGroup.peopleArray {
            let unit = u as! SingleUnit
            if (unit.modelInstance != nil) {
                unit.modelInstance!.color = player.color
            }
        }
    }
    
    private func axialToWorld(_ q: Int, _ r: Int) -> (x: Float, y: Float) {
        let x = 3.0 / 2.0 * Float(q) // x value
        let z = Float(3).squareRoot() * (Float(r) + Float(q) / 2) // z value
        
        return (x,z)
    }
    
    // Update the models for the units based on which units are inside of the unit group
    public func updateModels() {
        squareSize = Int(Float(unitGroup.peopleArray.count).squareRoot()) + 1

        for u in unitGroup.peopleArray {
            let unit = u as! SingleUnit
            if (unit.modelInstance == nil && !unit.dead) {
                // Add a new model for a new unit
                // If the model hasn't been loaded yet, load it
                if (unitModels[unit.getModelName()] == nil) {
                    do {
                        try unitModels[unit.getModelName()] = ModelReader.read(objPath: unit.getModelName())
                    } catch {
                        print("There was a problem initializing this tile model: \(error)")
                    }
                }
                let model = unitModels[unit.getModelName()]!
                let modelInst = ModelInstance(model: model)

                unit.modelInstance = modelInst
                unit.modelInstance!.color = owner!.color
                Renderer.addInstance(inst: modelInst)
            }
            else if (unit.dead) {
                if (unit.modelInstance != nil) {
                    Renderer.removeInstance(inst: unit.modelInstance!)
                }
            }
        }
    }

    // Sets what the unit group is walking towards
    public func setTarget(_ target : PathFindingTarget) {
        self.target = target
        self.movePath = target.getPathToTarget(from: Point2D(position))
    }
}

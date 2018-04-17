//
//  ViewController.swift
//  FingerGod
//
//  Created by Aaron Freytag on 2018-02-15.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import UIKit
import GLKit

let ScreenWidth = UIScreen.main.bounds.size.width
let ScreenHeigh = UIScreen.main.bounds.size.height

class ViewController: GLKViewController, Subscriber {
    
    private var game : Game!
    private var prevPanPoint = CGPoint(x: 0, y: 0)
    private var prevScale : Float = 1
    private var unitCount : Int!
    private var powerMenuHide : Bool!

    @IBOutlet weak var PowerLabel: UILabel!
    @IBOutlet weak var FollowerLabel: UILabel!
    @IBOutlet weak var GoldLabel: UILabel!
    @IBOutlet weak var ManaLabel: UILabel!
    var Exit: RoundButton!
    var Split: UIButton!
    var units: [RoundButton] = [RoundButton]()
    var powers: [RoundButton] = [RoundButton]()
    
    @IBAction func onButtonClick(_ sender: RoundButton) {
        game.input!.togglePowerMenu()
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loadisg the view, typically from a nib.
        Renderer.setup(view: self.view as! GLKView)
        PowerLabel.text = "Off"
        game = FingerGodGame()
        self.unitMenu()
        EventDispatcher.subscribe("UpdatePlayerUI", self)
        EventDispatcher.subscribe("AllyClick", self)
        EventDispatcher.subscribe("AddPowerButton", self)
    }
    
    @IBAction func onTap(_ recognizer: UITapGestureRecognizer) {
        game.input!.tapScreen(coord: recognizer.location(in: self.view))
    }
    
    @IBAction func onPan(recognizer: UIPanGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.began) {
            prevPanPoint = CGPoint(x: 0, y: 0)
        }
        let point = recognizer.translation(in: self.view)
        let diff = CGPoint(x: point.x - prevPanPoint.x, y: point.y - prevPanPoint.y)
        prevPanPoint = point
        
        let w = UIScreen.main.bounds.size.width
        Renderer.camera.move(x: Float(-diff.x * 10 / w), y: 0, z: Float(-diff.y * 10 / w))
    }
    
    @IBAction func onPinch(recognizer: UIPinchGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.began) {
            prevScale = 1
        }
        let scale = Float(recognizer.scale)
        let diff = scale - prevScale
        prevScale = scale;
        
        Renderer.camera.moveRelative(x: 0, y: 0, z: -diff * 4)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func update() {
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        super.glkView(view, drawIn: rect)
        game.update()
        Renderer.draw(drawRect: rect)
    }
    
    func unitMenu() {
        Exit = RoundButton.init()
        Exit.frame = CGRect.init(x: ScreenWidth - 110, y: 345, width: 15, height: 15)
        Exit.cornerRadius = 7.5
        Exit.borderWidth = 1
        Exit.borderColor = UIColor.red
        Exit.setTitle("X", for: .normal)
        Exit.setTitleColor(UIColor.red, for: .normal)
        Exit.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 6)
        Exit.addTarget(self, action: #selector(exitMenu), for: UIControlEvents.touchUpInside)
        self.view.addSubview(Exit)
        Exit.isHidden = true
        
        Split = UIButton.init()
        Split.frame = CGRect.init(x: ScreenWidth - 150, y: 300, width: 100, height: 30)
        Split.setTitle("Split Group", for: .normal)
        Split.setTitleColor(UIColor.blue, for: .normal)
        Split.backgroundColor = UIColor.lightGray
        Split.addTarget(self, action: #selector(splitMenu), for: UIControlEvents.touchUpInside)
        self.view.addSubview(Split)
        Split.isHidden = true
    }
    
    @objc func splitMenu() {
        Split.isHidden = true
        for i in 1...unitCount {
            var btn = RoundButton.init()
            let pos = (i * 30) + 150
            btn.frame = CGRect.init(x: Int(ScreenWidth - 50), y: pos, width: 30, height: 30)
            btn.cornerRadius = 15
            btn.borderWidth = 1
            btn.borderColor = UIColor.black
            btn.addTarget(self, action: #selector(moveUnit), for: UIControlEvents.touchUpInside)
            self.view.addSubview(btn)
            units.append(btn)
        }
    }
    
    @objc func exitMenu() {
        Exit.isHidden = true
        Split.isHidden = true
        
        for unit in units {
            unit.removeFromSuperview()
        }
        
        while (units.count > 0) {
            units.remove(at: 0)
        }
        unitCount = 0
    }
    
    @objc func moveUnit() {
        //TODO: Put Unit Group Splitting here
        print("moving unit away")
    }

    func notify(_ eventName: String, _ params: [String : Any]) {
        switch(eventName) {
        case "UpdatePlayerUI":
            FollowerLabel.text = (params["Followers"]! as! String)
            GoldLabel.text = (params["Gold"]! as! String)
            ManaLabel.text = (params["Mana"]! as! String)
            break
   
        case "AllyClick":
            print("works")
            Split.isHidden = false;
            Exit.isHidden = false;
            unitCount = (params["unitCount"]! as! Int)
            
        case "AddPowerButton":
            let btn = (params["button"]! as! RoundButton)
            let pos = (params["pos"]! as! Int)
            btn.frame = CGRect.init(x: Int(ScreenWidth - 350), y: 120 + pos, width: 30, height: 30)
            self.view.addSubview(btn)
            
        default:
            break
        }
    }


}


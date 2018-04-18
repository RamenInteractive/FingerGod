//
//  TitleController.swift
//  FingerGod
//
//  Created by Niko Lauron on 2018-04-11.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import UIKit
import GLKit
import AVFoundation

class TitleController: GLKViewController, Subscriber {
     var audioPlayer: AVAudioPlayer!
    
    private var game : Game!
    
    @IBOutlet weak var optionsBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    
    @IBOutlet var optionsItems: [UIButton]!
    override func viewDidLoad() {
        super.viewDidLoad()
        Renderer.setup(view: self.view as! GLKView)
        game = TitleScreenGame()
        startBtn.layer.cornerRadius = startBtn.frame.height/1.5
        optionsBtn.layer.cornerRadius = optionsBtn.frame.height/1.5
        optionsItems.forEach{(optBtn) in
            optBtn.layer.cornerRadius=optBtn.frame.height/1.5
            optBtn.isHidden = true
        }
        
        let url = Bundle.main.url(forResource: "Duel With Ares", withExtension: "mp3")
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }catch let error as NSError{
            print(error.debugDescription)
        }

    }
    
    @IBAction func optionSelection(_ sender: UIButton) {
        optionsItems.forEach{(optBtn) in
            optBtn.isHidden = !optBtn.isHidden   }
    }
    
    @IBAction func pressedOptions(_ sender: UIButton) {
    }
    @IBAction func stopLoadingMusic(_ sender: UIButton) {
        if(audioPlayer.isPlaying){
            audioPlayer.pause()
        }
    }
    func update() {
        
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        super.glkView(view, drawIn: rect)
        game.update()
        Renderer.draw(drawRect: rect)
    }
    
    func notify(_ eventName: String, _ params: [String : Any]) {
    
    }
}

//
//  ViewController.swift
//  Chorister
//
//  Created by Ryo Kato on 12/05/2015.
//  Copyright (c) 2015 Ryo Kato. All rights reserved.
//

import UIKit
import Chorister

class ViewController: UIViewController {
    var audioContainer = MusicContainer(repeats: true)

    @IBAction func ButtonAPushed(sender: UIButton) {
        audioContainer.changeAudio(NSURL(string: "https://s3.amazonaws.com/cc0-tunes/nichecom/a_new_beginning.mp3")!)
    }
    
    
    @IBAction func ButtonBPushed(sender: UIButton) {
        print("b pushed")
        audioContainer.changeAudio(NSURL(string: "https://s3.amazonaws.com/cc0-tunes/nichecom/lets_dance.mp3")!)
    }
    
    @IBAction func ButtonCPushed(sender: UIButton) {
        audioContainer.changeAudio(NSURL(string: "https://s3.amazonaws.com/cc0-tunes/nichecom/spotting.mp3")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
 
    }
    
    // https://github.com/katryo/Chorister/blob/master/Example/Chorister/Tunes/a_new_beginning.mp3?raw=true

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        audioContainer.reset()
    }

}

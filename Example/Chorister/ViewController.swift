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

    @IBAction func buttonDPushed(_ sender: Any) {
          audioContainer.changeAudio(url: NSURL(string: "https://s3.amazonaws.com/cc0-tunes/nichecom/a_new_beginning.mp3")!)
    }
    
    @IBAction func resetPushed(_ sender: UIButton) {
        audioContainer.reset()
    }
    
    @IBAction func buttonBPushed(_ sender: UIButton) {
    audioContainer.changeAudio(url: NSURL(string: "https://s3.amazonaws.com/cc0-tunes/nichecom/lets_dance.mp3")!)
    }

    @IBAction func buttonCPushed(_ sender: UIButton) {
        audioContainer.changeAudio(url: NSURL(string: "https://s3.amazonaws.com/cc0-tunes/nichecom/spotting.mp3")!)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        audioContainer.reset()
    }

}

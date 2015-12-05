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
    var audioContainer = StreamingAudioCacheContainer(repeats: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        audioContainer.reset()
    }

}


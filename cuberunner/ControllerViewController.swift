//
//  ControllerViewController.swift
//  cuberunner
//
//  Created by Joey Muia on 2016-04-01.
//  Copyright © 2016 Joey Muia. All rights reserved.
//

import UIKit
import SocketIOClientSwift

class ControllerViewController: UIViewController {
    @IBOutlet weak var gameIdLabel: UILabel!
    
    var gameId: String!
    
    let socket = SocketIOClient(socketURL: NSURL(string: "http://localhost:8080")!, options: [.Log(true)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameIdLabel.text = gameId
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
}

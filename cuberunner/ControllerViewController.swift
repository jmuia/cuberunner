//
//  ControllerViewController.swift
//  cuberunner
//
//  Created by Joey Muia on 2016-04-01.
//  Copyright © 2016 Joey Muia. All rights reserved.
//

import CoreMotion
import UIKit
import SocketIOClientSwift

class ControllerViewController: UIViewController {
    @IBOutlet weak var gameIdLabel: UILabel!
    
    var gameId: String!
    
    let socket = SocketIOClient(socketURL: NSURL(string: "http://localhost:8080")!, options: [.Log(true)])
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameIdLabel.text = gameId
        
        if !motionManager.deviceMotionAvailable {
            let uiAlert = UIAlertController(title: "Device Error", message: "Device is not supported.", preferredStyle: .Alert)
            uiAlert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { action in self.transitionToMenu() }))
            self.presentViewController(uiAlert, animated: true, completion: nil)
            return
        }
        
        // TODO - connect to socket + setup handlers
        
        motionManager.deviceMotionUpdateInterval = 0.1
        let queue = NSOperationQueue()
        motionManager.startDeviceMotionUpdatesToQueue(queue) { (data, error) in
            data?.attitude.pitch < -0.05 // right-ish
            data?.attitude.pitch > 0.05 // left-ish
        }
        
        
        
    }
    
    func transitionToMenu() {
        if let menuViewController = storyboard!.instantiateViewControllerWithIdentifier("menu") as? MenuViewController {
            presentViewController(menuViewController, animated: true, completion: nil)
        }
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

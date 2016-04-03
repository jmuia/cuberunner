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
    @IBOutlet weak var tapToStartLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var hudImageView: UIImageView!
    
    var gameId: String!
    var gameActive = false
    var gamePaused = false
    
    var socket: SocketIOClient!
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameIdLabel.text = gameId
        tapToStartLabel.hidden = true
        pauseButton.hidden = true
        
        createSocket()
        addSocketHandlers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        socket.connect()
        
        if !motionManager.deviceMotionAvailable {
            let uiAlert = UIAlertController(title: "Device Error", message: "Device is not supported.", preferredStyle: .Alert)
            uiAlert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { action in self.transitionToMenu() }))
            self.presentViewController(uiAlert, animated: true, completion: nil)
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 0.01
        let queue = NSOperationQueue()
        motionManager.startDeviceMotionUpdatesToQueue(queue) { (data, error) in

            var rotation = -atan2(data!.gravity.y, data!.gravity.x)
            
            if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft {
               rotation += M_PI
            }

            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.hudImageView.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
            }
            
            var rot = 0.0
            if (data!.gravity.x > 0) {
                // right = +ve, left = -ve
                rot = -data!.gravity.y
            } else if (data!.gravity.x < 0) {
                // right = -ve, left = +ve
                rot = data!.gravity.y
            }
            
            if (self.gameActive && !self.gamePaused) {
                self.socket.emit("controller:input", ["id": self.gameId, "value": rot])
            }
        }
    }
    
    func createSocket() {
        socket = SocketIOClient(socketURL: NSURL(string: "http://cuberunner.herokuapp.com")!, options: [.Log(false), .ReconnectAttempts(0)])
    }
    
    func addSocketHandlers() {
        socket.on("connect") { data, ack in
            print("socket connected")
            self.activityIndicator.hidden = true
            self.tapToStartLabel.hidden = false
        }
        
        socket.on("game:finished") { data, ack in
            print("game completed")
        }
        
        socket.on("game:notfound") { data, ack in
            print ("game not found")
            let uiAlert = UIAlertController(title: "Code Error", message: "Game not found.", preferredStyle: .Alert)
            uiAlert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { action in self.transitionToMenu() }))
            self.presentViewController(uiAlert, animated: true, completion: nil)
            return
        }
        
        socket.on("reconnect") { data in
            print("reconnect")
            print(data.0)
        }
        
        socket.on("reconnectAttempt") { data in
            print("reconnect attempt")
            print(data.0)
        }
        
        socket.on("error") { data in
            print("error")
            print(data.0)
            
            self.socket.disconnect()
            self.socket.removeAllHandlers()
            
            let uiAlert = UIAlertController(title: "Server Error", message: data.0[0] as? String, preferredStyle: .Alert)
            uiAlert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { action in self.transitionToMenu() }))
            self.presentViewController(uiAlert, animated: true, completion: nil)
        }
        
        socket.on("disconnect") { data in
            print("socket disconnected")
            print (data.0)
        }
    }
    
    @IBAction func screenTapped(sender: AnyObject) {
        print("screen tapped")
        if (!gameActive) {
            socket.emit("controller:start", ["id": self.gameId])
            gameActive = true
            tapToStartLabel.hidden = true
            pauseButton.hidden = false
        }
    }
    
    @IBAction func pauseTapped(sender: AnyObject) {
        print("pause tapped")
        if (gamePaused) {
            print ("resumed")
            gamePaused = false
            socket.emit("controller:start", ["id": self.gameId])
            pauseButton.setTitle("Pause", forState: UIControlState.Normal)
        } else {
            print ("paused")
            gamePaused = true
            socket.emit("controller:pause", ["id": self.gameId])
            pauseButton.setTitle("Resume", forState: UIControlState.Normal)
        }
    }
    
    func rad2deg(rad: Double) -> Double {
        return (180/M_PI)*rad
    }
    
    override func viewDidDisappear(animated: Bool) {
        motionManager.stopDeviceMotionUpdates()
    }

    
    func transitionToMenu() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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

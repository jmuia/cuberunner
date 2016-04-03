//
//  ScannerViewController.swift
//  cuberunner
//
//  Created by Joey Muia on 2016-04-01.
//  Copyright © 2016 Joey Muia. All rights reserved.
//

import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var scanLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributedScanString = NSAttributedString(string: scanLabel.text!, attributes: [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSStrokeWidthAttributeName: NSNumber(float: -2),
            NSFontAttributeName: UIFont.systemFontOfSize(17.0)
        ])
        
        scanLabel.attributedText = attributedScanString
        scanLabel.hidden = true
        
        let attributedCancelString = NSAttributedString(string: (cancelButton.titleLabel?.text)!, attributes: [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSStrokeWidthAttributeName: NSNumber(float: -2),
            NSFontAttributeName: UIFont.systemFontOfSize(20.0)
        ])
        
        cancelButton.setAttributedTitle(attributedCancelString, forState: .Normal)
        
        cancelButton.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let input: AnyObject!
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            let uiAlert = UIAlertController(title: "Device Error", message: "Device is not supported.", preferredStyle: .Alert)
            uiAlert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { action in self.transitionToMenu() }))
            self.presentViewController(uiAlert, animated: true, completion: nil)
            return
        }
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(input as! AVCaptureInput)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        view.bringSubviewToFront(scanLabel)
        scanLabel.hidden = false
        
        view.bringSubviewToFront(cancelButton)
        cancelButton.hidden = false
        
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
        
        captureSession?.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                transitionToGame(metadataObj.stringValue)
            }
        }
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        transitionToMenu()
    }
    
    func transitionToMenu() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func transitionToGame(gameId: String) {
        
        if let controllerViewController = storyboard!.instantiateViewControllerWithIdentifier("controller") as? ControllerViewController {
            controllerViewController.gameId = gameId
            
            let pvc = self.presentingViewController!
            
            pvc.dismissViewControllerAnimated(false, completion: {
                pvc.presentViewController(controllerViewController, animated: false, completion: nil)
            })
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }


}

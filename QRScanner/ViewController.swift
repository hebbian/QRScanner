//
//  ViewController.swift
//  QRScanner
//
//  Created by Mohammad Rahman Habibi on 11/8/17.
//  Copyright © 2017 Habibi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    var isReading: Bool = false
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var borderView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.borderView = UIView()
        self.borderView?.layer.borderWidth = 2.0
        self.borderView?.layer.borderColor = UIColor.green.cgColor
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func startStopReading(_ sender: Any) {
        if self.isReading == false {
            if self.startReading() == true {
                self.captureSession?.startRunning()
                self.isReading = true
                self.scanButton.setTitle("STOP SCANNING", for: .normal)
            }
        } else {
            self.captureSession?.stopRunning()
            self.isReading = false
            self.scanButton.setTitle("START SCANNING", for: .normal)
        }
    }
    
    func startReading() -> Bool{
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            self.captureSession = AVCaptureSession()
            self.captureSession?.addInput(input)
            
        } catch {
            print(error)
            return false
        }
        let captureMetadataOutput = AVCaptureMetadataOutput()
        self.captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = self.scannerView.layer.bounds
        self.scannerView.layer.addSublayer(videoPreviewLayer!)
        
        self.scannerView.addSubview(self.borderView!)
        self.scannerView.bringSubview(toFront: self.borderView!)
 
        return true
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if metadataObj.type == AVMetadataObject.ObjectType.qr {
                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
                self.borderView?.frame = (barCodeObject?.bounds)!
                
                if metadataObj.stringValue != nil {
                    self.resultLabel.text = metadataObj.stringValue
                }
            }
        } else {
            self.borderView?.frame = CGRect.zero
        }
    }
    
}


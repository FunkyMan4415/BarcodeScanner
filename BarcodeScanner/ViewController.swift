//
//  ViewController.swift
//  BarcodeScanner
//
//  Created by Christian Dobrovolny on 20.10.17.
//  Copyright © 2017 Christian Dobrovolny. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var label: UILabel!
    // first steps:
    var captureDevice : AVCaptureDevice?
    var captureSession : AVCaptureSession?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var greenbox : UIView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
            
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(previewLayer!)
            
            
            greenbox = UIView()
            
            if let qrCodeFrameView = greenbox {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }

            captureSession?.startRunning()
            
            view.bringSubview(toFront: flashButton)
        } catch {
            fatalError()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    
    @IBAction func activateFlash(_ sender: UIButton) {
        try! captureDevice?.lockForConfiguration()
        if (captureDevice?.hasTorch)! {
            if(captureDevice?.isTorchActive)! {
                captureDevice?.torchMode =  AVCaptureDevice.TorchMode.off
            } else {
                captureDevice?.torchMode = AVCaptureDevice.TorchMode.on
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            greenbox?.frame = CGRect.zero
        } else {
            if let la = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                let barcodeObject = previewLayer?.transformedMetadataObject(for: la)
                greenbox?.frame = (barcodeObject?.bounds)!
                view.bringSubview(toFront: label)
                label.text = la.stringValue
                print("captured")
            }
        }
    }
}


//
//  QRCodeViewController.swift
//  HDMC
//
//  Created by injungkim on 07/08/2018.
//  Copyright © 2018 injungkim. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRCodeViewControllerDelegate {
    func sendURL(url: URL)
}

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    let systemSoundId : SystemSoundID = 1016
    var delegate: QRCodeViewControllerDelegate?
    
    override func viewDidDisappear(_ animated: Bool) {
        captureSession?.stopRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        captureSession?.startRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //AVCaptureDevice allows us to reference a physical capture device (video in our case)
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        if let captureDevice = captureDevice {
            
            do {
                captureSession = AVCaptureSession()
                
                // CaptureSession needs an input to capture Data from
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession?.addInput(input)
                
                // CaptureSession needs and output to transfer Data to
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession?.addOutput(captureMetadataOutput)
                
                //We tell our Output the expected Meta-data type
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = [.code128, .qr, .ean13, .ean8, .code39, .upce, .aztec, .pdf417]
                
                captureSession?.startRunning()
                
                //The videoPreviewLayer displays video in conjunction with the captureSession
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreviewLayer?.videoGravity = .resizeAspectFill
                videoPreviewLayer?.frame = view.layer.bounds
                view.layer.addSublayer(videoPreviewLayer!)
            }
            catch {
                print("Error")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            print("no objects returned")
            return
        }
        
        let metaDataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        guard let StringCodeValue = metaDataObject.stringValue else {
            return
        }
        
        //transformedMetaDataObject returns layer coordinates/height/width from visual properties
        guard let _ = videoPreviewLayer?.transformedMetadataObject(for: metaDataObject) else {
            return
        }
        
        AudioServicesPlayAlertSound(systemSoundId)
        
        if let url = URL(string: StringCodeValue) {
            delegate?.sendURL(url: url)
            captureSession?.stopRunning()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

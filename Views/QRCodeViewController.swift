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

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UsingThread {
    
    // UI Components (_Member Variable)
    var scanStatusLabel: UILabel?
    
    // Member Variable
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    let systemSoundId : SystemSoundID = 1016
    var delegate: QRCodeViewControllerDelegate?
    var checkDuplicateArray: Array<String>?
    
    override func viewDidDisappear(_ animated: Bool) {
        captureSession?.stopRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        captureSession?.startRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize array
        checkDuplicateArray = Array<String>()
        
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
                // frame setting
                let value: CGFloat = view.frame.size.width/2
                let x: CGFloat = 0.25
                let y: CGFloat = (1 - value / view.frame.width) / 2
                let width: CGFloat = 0.5
                let height: CGFloat = value / view.frame.size.height
                
                captureMetadataOutput.rectOfInterest = CGRect(x: y,
                                                              y: 1 - x - width,
                                                              width: height,
                                                              height: width)
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
                
                // The QRCode capture frame
                let maskLayer = CAShapeLayer()
                maskLayer.fillRule = kCAFillRuleEvenOdd
                maskLayer.frame = view.frame
                
                let maskLayerPath = UIBezierPath()
                maskLayerPath.append(UIBezierPath(rect: maskLayer.frame))
                let maskFrame = CGRect(x: view.frame.size.width * x,
                                       y: view.frame.size.height * y,
                                       width: view.frame.size.width * width,
                                       height: view.frame.size.height * height)
                maskLayerPath.append(UIBezierPath(roundedRect: maskFrame, cornerRadius: 10))
                maskLayer.path = maskLayerPath.cgPath
                
                let imageLayer = CALayer()
                imageLayer.frame =  view.frame
                imageLayer.backgroundColor = UIColor(white: 0, alpha: 0.6).cgColor
                imageLayer.mask = maskLayer
                view.layer.addSublayer(imageLayer)
                
                // QRCode scanning status
                scanStatusLabel = UILabel(frame: CGRect(x: 15,
                                                        y: maskFrame.origin.y + maskFrame.size.height + 30,
                                                        width: view.frame.size.width - 30,
                                                        height: 40))
                scanStatusLabel?.font = UIFont.systemFont(ofSize: 20)
                scanStatusLabel?.textAlignment = .center
                scanStatusLabel?.textColor = .white
                scanStatusLabel?.text = "스캔 준비가 완료되었어요."
                view.addSubview(scanStatusLabel!)
            }
            catch {
                print("CaptureSession Error")
            }
        }
        
        // Add button
        let backButton: UIButton = UIButton(frame:
            CGRect(
                x: view.frame.width / 3,
                y: view.frame.height - (view.frame.height / 8),
                width: view.frame.width / 3,
                height: 100)
        )
        backButton.addTarget(self, action: #selector(closeViewController), for: .touchUpInside)
        backButton.setTitle("Finish", for: .normal)
        view.addSubview(backButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Selector Method
    @objc
    func closeViewController() {
        dismiss(animated: true) {
            self.captureSession?.stopRunning()
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        syncThread {
            if metadataObjects.count == 0 {
                print("no objects returned")
                return
            }
            
            let metaDataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            guard let StringCodeValue = metaDataObject.stringValue else {
                return
            }
            
            if let url = URL(string: StringCodeValue),
                let host = url.host {
                if (self.checkDuplicateArray?.contains(host))! {
                    return
                }
                
                //transformedMetaDataObject returns layer coordinates/height/width from visual properties
                guard let _ = self.videoPreviewLayer?.transformedMetadataObject(for: metaDataObject) else {
                    return
                }
            
                AudioServicesPlayAlertSound(self.systemSoundId)
            
                self.checkDuplicateArray?.append(host)
                self.scanStatusLabel?.text = "'\(host)'원생 확인완료"
                self.delegate?.sendURL(url: url)
            }
        }
    }
    
}

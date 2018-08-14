//
//  ViewController.swift
//  HDMC
//
//  Created by injungkim on 07/08/2018.
//  Copyright © 2018 injungkim. All rights reserved.
//

import UIKit
import WebKit

// MARK: - Call app names
let CALL_APP_QRCODE             = "callQrcode"
let CALL_APP_FCM                = "FCMID"

// MARK: - Call script names
let CALL_SCRIPT_QRCODE          = "onQrcodeRead"
let CALL_SCRIPT_FCM             = "getFcmId"

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, QRCodeViewControllerDelegate {
    
    // UI Components (_Member Variable)
    // WKWebView before IOS 11.0 (NSCoding support was broken in previous versions)
    var webView: WKWebView!
    
    // Member Variable
    let contentController = WKUserContentController()
    let configuration = WKWebViewConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize WKWebView
        configuration.userContentController = contentController
        webView = WKWebView()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        
        // Recognize Auto Layout
        webView.translatesAutoresizingMaskIntoConstraints = false

        // Add subview
        self.view.addSubview(webView)
        
        // Add constraints
        if #available(iOS 11.0, *) {
            let safeArea = self.view.safeAreaLayoutGuide
            webView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
            webView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        } else {
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        // JS -> Native Application
        webView.configuration.userContentController.add(self, name: CALL_APP_QRCODE)
        webView.configuration.userContentController.add(self, name: CALL_APP_FCM)
        
        // TODO: Test용 나중에 지워야 함
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            for record in records {
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {
                    print("Cache clear success.")
                })
            }
        }
        
        // 초기 url 삽입
        webView.load(URLRequest(url: URL(string: "https://howdoesmychild.firebaseapp.com")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showQRCodeView" {
            let qrcodeViewController = segue.destination as! QRCodeViewController
            qrcodeViewController.delegate = self
        }
    }

    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case CALL_APP_QRCODE:
            self.performSegue(withIdentifier: "showQRCodeView", sender: self)
        case CALL_APP_FCM:
            webView.evaluateJavaScript("\(CALL_SCRIPT_FCM)('\(HDMCStore.sharedInstance.firebaseFCMID)')") { (result, error) in
                
            }
        default:
            break
        }
    }
    
    // MARK: - QRCodeViewControllerDelegate
    func sendURL(url: URL) {
        webView.evaluateJavaScript("\(CALL_SCRIPT_QRCODE)('\(url.absoluteString)')") { (result, error) in
            
        }
    }

}

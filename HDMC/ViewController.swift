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
let CALL_APP_QRCODE             = "QRcode"

// MARK: - Call script names
let CALL_SCRIPT_QRCode          = "QRCode()"

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
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
        webView = WKWebView(frame: self.view.frame, configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        // JS -> Native Application
        webView.configuration.userContentController.add(self, name: CALL_APP_QRCODE)
        
        // Native Application -> JS
        webView.evaluateJavaScript(CALL_SCRIPT_QRCode) { (result, error) in
            
        }
        
        // Add subview
        self.view.addSubview(webView)

        // 초기 url 삽입
        webView.load(URLRequest(url: URL(string: "https://google.com")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == CALL_APP_QRCODE {
            // qrcode를 불렀을 때 동작
        }
    }

}

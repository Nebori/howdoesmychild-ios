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
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(3), execute: {
            // 뷰를 너무 빨리 생성하면 윈도우가 순서가 어긋나서 상단에 뷰가 표시되지 않는다.
            // 이런 문제를 해결하기 위해서 잠시 후 화면을 생성하도록 하자.
            // 일반 로직에서는 문제가 되지 않지만 테스트에서는 이렇게 문제시 될 수 있음
            self.performSegue(withIdentifier: "showQRCodeView", sender: self)
        })
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
        if message.name == CALL_APP_QRCODE {
            // qrcode를 불렀을 때 동작
        }
    }
    
    // MARK: - QRCodeViewControllerDelegate
    func sendURL(url: URL) {
        print(url)
    }

}

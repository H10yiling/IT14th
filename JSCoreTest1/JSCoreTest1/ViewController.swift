//
//  ViewController.swift
//  JSCoreTest1
//
//  Created by 侯懿玲 on 2022/10/5.
//

import UIKit
//import JavaScriptCore
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    lazy var webView: WKWebView = {
        // 建立WKPreferences
        let preferences = WKPreferences()
        // 開啟js
        preferences.javaScriptEnabled = true
        // 建立WKWebViewConfiguration
        let configuration = WKWebViewConfiguration()
        // 設定WKWebViewConfiguration的WKPreferences
        configuration.preferences = preferences
        // 建立WKUserContentController
        let userContentController = WKUserContentController()
        // 配置WKWebViewConfiguration的WKUserContentController
        configuration.userContentController = userContentController
        // 給WKWebView與Swift互動起一個名字：callbackHandler，WKWebView給Swift發訊息的時候會用到
        // 此句要求實現WKScriptMessageHandler協議
        configuration.userContentController.add(self, name: "callbackHandler")
        
        // 建立WKWebView
        var webView = WKWebView(frame: self.view.frame, configuration: configuration)
        // 讓webview翻動有回彈效果
        webView.scrollView.bounces = true
        // 只允許webview上下滾動
        webView.scrollView.alwaysBounceVertical = true
        
        // 此句要求實現WKNavigationDelegate協議
        webView.navigationDelegate = self
        
        return webView
    }()
    
    // 載入html
    let html = try! String(contentsOfFile: Bundle.main.path(forResource: "ApexLinkTest", ofType: "html")!, encoding: String.Encoding.utf8)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "WebView與JS互動"
        view.addSubview(webView)
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    // 載入完畢以後執行
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 呼叫JS方法
//        webView.evaluateJavaScript("sayHello('WebView你好！')") { (result, err) in
//            // result是JS返回的值
//            print(result, err)
//        }
        webView.evaluateJavaScript("""
module.exports = {
    setServerUrl,
    createCredential,
    loadXLH: fromXLH
};
"""
        ) { result, err in
            print(result, err)
        }
        
        // evaluateJavaScript("document.body.innerHTML") // 呼叫 HTML 檔裡 body 裡的文字
    }
    
    // Swift方法，可以在JS中呼叫
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }
}


// MARK: -
/*
 https://www.appcoda.com.tw/javascriptcore-swift/
 
 
 https://www.gushiciku.cn/pl/gafV/zh-tw
 */

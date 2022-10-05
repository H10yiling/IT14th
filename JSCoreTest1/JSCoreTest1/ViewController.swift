//
//  ViewController.swift
//  JSCoreTest1
//
//  Created by 侯懿玲 on 2022/10/5.
//

import UIKit
import JavaScriptCore

class ViewController: UIViewController {
    
    var jsContext: JSContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initializeJS()
        helloWorld()
    }
    
    func initializeJS() {
        
        jsContext = JSContext()
        
        // 指定 jssource.js 檔案路徑
        if let jsSourcePath = Bundle.main.path(forResource: "test-1", ofType: "js") {
            do {
                // 將檔案內容加載到 String
                let jsSourceContents = try String(contentsOfFile: jsSourcePath)
                print("log jsSourcePath. ",jsSourcePath)
                
                // 通過 jsContext 對象，將 jsSourceContents 中包含的腳本添加到 Javascript 運行時
                jsContext.evaluateScript(jsSourceContents)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        else{
            print("ERR path")
        }
    }
    func helloWorld() {
        if let variableHelloWorld = self.jsContext.objectForKeyedSubscript("helloWorld"){
            print("log variableHelloWorld. ",variableHelloWorld)
        }
    }
}


// MARK: -
/*
 https://www.appcoda.com.tw/javascriptcore-swift/
 */

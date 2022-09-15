//
//  MainVC.swift
//  AutoFillDemo
//
//  Created by 侯懿玲 on 2022/8/9.
//

import UIKit
import AuthenticationServices

class MainVC: UIViewController {
    
    @IBOutlet weak var lbText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startNotificationCenter()
    }
    
    /// 設定頁自動帶入的 NotificationServer
    func startNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(statusAutofill(notification:)),
            name: NSNotification.Name("statusAutofill"),
            object:nil
        )
    }
    
    // MARK: - Notification 監聽，裝置的藍芽是否開啟 func
    @objc func statusAutofill(notification: NSNotification) {
        let status = notification.userInfo?["status"] as! Bool
        DispatchQueue.main.async {
            if status {
                self.lbText.text = "state.isEnabled"
            }
            else {
                self.lbText.text = "state.isDisabled"
            }
        }
    }
}

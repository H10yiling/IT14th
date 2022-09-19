//
//  MainViewController.swift
//  BiometricsDemo
//
//  Created by 侯懿玲 on 2022/8/10.
//

import UIKit
// import 我們身份驗證的框架
import LocalAuthentication

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logging(_ sender: UIButton) {
        
        // 創建 LAContext 實例
        let context = LAContext()
        
        // 設置取消按鈕標題
        context.localizedCancelTitle = "Cancel"
        
        // 宣告一個變數接收 canEvaluatePolicy 返回的錯誤
        var error: NSError?
        
        // 評估是否可以針對給定方案進行身份驗證
        // deviceOwnerAuthentication 支援 Face ID 、 Touch ID 驗證
        // deviceOwnerAuthenticationWithBiometrics 支援 Face ID 、 Touch ID 、 裝置密碼 驗證
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            // 描述使用身份辨識的原因
            let reason = "Log in to your account"
            
            // 評估指定方案
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                if success {
                    DispatchQueue.main.async {
                        print("Login Successful")
                    }
                }
                else {
                    DispatchQueue.main.async {
                        print("Login Failed",error?.localizedDescription as Any)
                    }
                }
            }
        }
        else {
            // 若使用者沒有設置生物辨識，會自動導向 設定 -> Face/Touch ID & Passcode
            if error?.localizedDescription == "Biometry is not enrolled." {
                print("unset Face ID")
                let alertController = UIAlertController(title: "Biometrics can't used", message: "please add Face ID", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "ok", style: .default) { action in
                    guard let url = URL(string: "App-prefs:PASSCODE") else { return }
                    if (UIApplication.shared.canOpenURL(url)) {
                        UIApplication.shared.open(url) { success in
                            print(success)
                        }
                    }
                }
                alertController.addAction(confirmAction)
                self.present(alertController, animated: true, completion: nil)
            }
            print("Failed",error?.localizedDescription as Any)
        }
    }
}

// MARK: - 文案

/*
 iPhoneOS 的限制:
 Touch ID ： iOS 8 以上
 Face ID ： iOS 11 以上 (需使用者同意開啟 FaceID 權限)
 
 如果你的 App 有需要加入 Face ID 的話，那我們必須在 Info.plist 新增 NSFaceIDUsageDescription 的 key。
 
 在我們使用任何生物辨識技術的專案中，我們需要在 App 中的 Info.plist 文件中加入 NSFaceIDUsageDescription 的 key。
 如果沒有這個 key，系統將不允許你的 App 使用 Face ID。
 這個 key 的值是系統在你的 App 首次嘗試使用 Face ID 時向用戶顯示的 String。
 此 String 應該清楚的解釋你的 App 需要訪問此身份驗證機制的原因。
 但 Touch ID 的部分，系統不需要另外加上類似的用法說明。
 
 LAPolicy type : Int
 支援 Face ID 、 Touch ID 驗證
 deviceOwnerAuthentication = 1
 支援 Face ID 、 Touch ID 、 裝置密碼 驗證
 deviceOwnerAuthenticationWithBiometrics = 2
 
 測試結果：
 deviceOwnerAuthentication：
 若本身手機沒設 Face ID ，程式會自動使用密碼登入
 deviceOwnerAuthenticationWithBiometrics：
 若本身手機沒設 Face ID ，則會丟出 Failed Optional("Biometry is not enrolled.")
 
 Error事件：
 kLAErrorAuthenticationFailed = 驗證資訊出錯
 kLAErrorUserCancel = 使用者取消驗證
 kLAErrorUserFallback = 使用者選擇其他驗證方式
 kLAErrorSystemCancel = 被系統取消
 kLAErrorPasscodeNotSet = iPhone沒設定密碼
 kLAErrorTouchIDNotAvailable = 使用者裝置不支援Touch ID
 kLAErrorTouchIDNotEnrolled = 使用者裝置沒有設定Touch ID
 kLAErrorTouchIDLockout = 功能被鎖定(五次)，下一次需要輸入手機密碼
 kLAErrorAppCancel = 在驗證中被其他app終止
 */

// MARK: - 參考資料

/*
 Biometrics 生物辨識 ( Swift )
 https://medium.com/@molder1007/biometrics-%E7%94%9F%E7%89%A9%E8%BE%A8%E8%AD%98-swift-3e08e3f5cec3
 
 Swift — 玩玩 Touch ID & FaceID 驗證
 https://medium.com/jeremy-xue-s-blog/swift-%E7%8E%A9%E7%8E%A9-touch-id-faceid-%E9%A9%97%E8%AD%89-d30be0ac803b
 
 
 iOS 捷徑 App URL Scheme 清單
 https://www.tech-girlz.com/2021/01/shortcuts-url-scheme.html
 
 Apple 設置的 iOS URL 方案的完整列表
 https://medium.com/@contact.jmeyers/complete-list-of-ios-url-schemes-for-apple-settings-always-updated-20871139d72f
 
 ios-settings-urls
 https://github.com/FifiTheBulldog/ios-settings-urls/blob/master/settings-urls.md
 */


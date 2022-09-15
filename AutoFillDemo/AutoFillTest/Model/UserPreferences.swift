//
//  UserPreferences.swift
//  AutoFillTest
//
//  Created by 侯懿玲 on 2022/7/19.
//

import Foundation

class UserPreferences {
    
    static let shared = UserPreferences()
    
    private let userPreferences: UserDefaults
    
    private init() {
        userPreferences = UserDefaults.standard
    }
    
    enum UserPreference: String {
        case QrCodeNFCDataInfo // 從 QrCode 或是 NFC 卡片取得的資訊
        case isEnableLocalAuthentication // 是否啟動生物辨識功能
        case isFinishFirstSetting // 是否完成首次設定
        case isLockApp // App 是否上鎖
        
        case saveNum // 安全碼
        case arrayData // array
    }
    
    var QrCodeNFCDataInfo: String {
        get { return userPreferences.string(forKey: UserPreference.QrCodeNFCDataInfo.rawValue) ?? "" }
        set { userPreferences.set(newValue, forKey: UserPreference.QrCodeNFCDataInfo.rawValue) }
    }
    
    var isEnableLocalAuthentication: Bool {
        get { return userPreferences.bool(forKey: UserPreference.isEnableLocalAuthentication.rawValue) }
        set { userPreferences.set(newValue, forKey: UserPreference.isEnableLocalAuthentication.rawValue) }
    }
    
    var isFinishFirstSetting: Bool {
        get { return userPreferences.bool(forKey: UserPreference.isFinishFirstSetting.rawValue) }
        set { userPreferences.set(newValue, forKey: UserPreference.isFinishFirstSetting.rawValue) }
    }
    
    var isLockApp: Bool {
        get { return userPreferences.bool(forKey: UserPreference.isLockApp.rawValue) }
        set { userPreferences.set(newValue, forKey: UserPreference.isLockApp.rawValue) }
    }
    
    var saveNum: String {
        get { return userPreferences.string(forKey: UserPreference.saveNum.rawValue) ?? "" }
        set { userPreferences.set(newValue, forKey: UserPreference.saveNum.rawValue) }
    }
    
    var arrayData: Array<Any> {
        get { return userPreferences.array(forKey: UserPreference.arrayData.rawValue) ?? AutoFillArray.shared.autofillArray}
        set { userPreferences.set(newValue, forKey: UserPreference.arrayData.rawValue) }
    }
}

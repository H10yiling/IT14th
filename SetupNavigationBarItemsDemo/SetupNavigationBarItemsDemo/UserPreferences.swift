//
//  UserPreferences.swift
//  CmoreKeyDemo
//
//  Created by Leo Ho on 2022/6/24.
//

import Foundation

class UserPreferences {
    
    static let shared = UserPreferences()
    
    private let userPreference: UserDefaults
    
    private init() {
        // 設定要儲存的值(value) 及 key
        userPreference = UserDefaults.standard
    }
    
    enum UserPreference: String {
        case numIndex   // 顯示在 SecondViewController 的數值
    }
    
    var numIndex: String {
        get { return userPreference.string(forKey: UserPreference.numIndex.rawValue) ?? "0" }
        set { userPreference.set(newValue, forKey: UserPreference.numIndex.rawValue) }
    }
}

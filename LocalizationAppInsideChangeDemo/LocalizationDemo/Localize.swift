//
//  LocalizeUtils.swift
//  LocalizationDemo
//
//  Created by 侯懿玲 on 2022/9/23.
//

import UIKit

class Localize: NSObject {
    
    static let shared = Localize()
    
    /// 取得 Label 值
    ///
    /// - Parameters:
    ///   - withText: 多國語系檔的 key 值
    ///   - withLocalizationFileNmae: 多國語系檔的檔名
    /// - Returns: String
    func localizedText(withText key: String, withLocalizationFileNmae localizationFileNmae: String) -> String {
        // 取得 Bundle 下的的多國語系檔
        let path = Bundle.main.path(forResource: localizationFileNmae, ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        // 依 key 值和 Bundle 的多國語系檔取得對應的 value
        return NSLocalizedString(key, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    /// 依語系檔裡的 key 取得 value 值
    ///
    /// - Parameters:
    ///   - withImageName: 多國語系檔的 key 值
    ///   - withLocalizationFileNmae: 多國語系檔的檔名
    /// - Returns: String
    func localizedImage(withImageName key: String, withLocalizationFileNmae localizationFileNmae: String) -> UIImage {
        // 取得 Bundle 下的的多國語系檔
        let path = Bundle.main.path(forResource: localizationFileNmae, ofType: "lproj")
        let bundle = Bundle(path: path!)

        // 依 key 值和 Bundle 的多國語系檔取得對應的 value
        return UIImage(named: NSLocalizedString(key,bundle: bundle!, comment: "")) ?? UIImage(systemName: "questionmark.folder")!
    }
}

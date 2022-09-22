//
//  MainViewController.swift
//  LocalizationDemo
//
//  Created by 侯懿玲 on 2022/9/20.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var hiLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hiLabel.text = self.transalte(LocalizedString: "Hi")
        
    }
    
    /// 簡便翻譯
    /// - Parameters:
    ///   - key: 在 LocalizableStrings 裡面定義的 Key
    /// - Returns: 在 LocalizableStrings 裡面定義的 Value
    func transalte(LocalizedString key: String) -> String {
        // 設定多國語系，填入key值
        return NSLocalizedString(key, comment: "")
    }
}

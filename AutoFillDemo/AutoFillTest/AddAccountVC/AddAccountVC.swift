//
//  AddAccountVC.swift
//  AutoFillTest
//
//  Created by 侯懿玲 on 2022/7/19.
//

import UIKit
import AuthenticationServices
import CoreFoundation

class AddAccountVC: ASCredentialProviderViewController {
    
    @IBOutlet weak var txfAccount: UITextField!
    @IBOutlet weak var txfPassword: UITextField!
    @IBOutlet weak var lbIdAndURL: UILabel!
    @IBOutlet weak var btnAddFinish: UIButton!
    
    // 宣告這個畫面會遵循 AddAccountProtocol，並請委任目標（delegate）去處理 AddAccountProtocol 的事件
    var delegate: AddAccountVCCellItemProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        setInit()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        txfAccount.textContentType = .username
        txfPassword.textContentType = .password
    }
    
    
    func setInit() {
        // Button
        setupbtnLogin(buttonTitleColor: .white, buttonBackgroundColor: .systemGray4, buttonEnabled: true)
        // UILabel
        lbIdAndURL.text = "\(IdAndURLText.shared.text)"
    }
    
    
    func addAutofillAccount() {
        // 消失之後請委任目標去處理 arrayAdd 事件
        if lbIdAndURL.text != "" && txfAccount.text != "" && txfPassword.text != "" {
            delegate.arrayAdd(titleText: lbIdAndURL.text!, accountText: txfAccount.text!, passwordText: txfPassword.text!)
        } else {
            print("有空值")
        }
        
    }
    
    /// 設定 `登入按鈕` 的 Button 樣式
    /// - Parameters:
    ///   - buttonTitleColor: Button 文字顏色，預設為 UIColor.white
    ///   - buttonBackgroundColor: Button 背景色，預設為 UIColor.systemGray4
    ///   - buttonEnabled: Button 是否能用，預設為 false
    private func setupbtnLogin(buttonTitleColor: UIColor = .white, buttonBackgroundColor: UIColor = .systemGray4, buttonEnabled: Bool = true) {
        btnAddFinish.setTitle("save", for: .normal)
        btnAddFinish.layer.cornerRadius = btnAddFinish.bounds.height/6
        btnAddFinish.backgroundColor = buttonBackgroundColor
        btnAddFinish.setTitleColor(buttonTitleColor, for: .normal)
        btnAddFinish.isUserInteractionEnabled = buttonEnabled
    }
    

    
    // MARK: - IBAction
    
    @IBAction func touchBtnCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touchBtnAddFinish(_ sender: UIButton) {
        
        let _ = AutoFillVC()
        addAutofillAccount()
        self.dismiss(animated: true, completion: nil)
    }
    
}

protocol AddAccountVCCellItemProtocol {
    func arrayAdd(titleText: String, accountText: String, passwordText: String)
}

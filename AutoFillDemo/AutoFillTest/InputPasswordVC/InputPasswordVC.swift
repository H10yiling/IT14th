//
//  InputPasswordVC.swift
//  AutoFillTest
//
//  Created by 侯懿玲 on 2022/7/14.
//

import UIKit
import AuthenticationServices
class InputPasswordVC: ASCredentialProviderViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet var txfPassCode: [UITextField]!
    @IBOutlet weak var vActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    
    var code: String = "" // 用來取得輸入的密碼
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserPreferences.shared.saveNum = "111111"
        setupUI()
    }
    
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        IdAndURLText.shared.text = serviceIdentifiers[0].identifier
        print(serviceIdentifiers[0].identifier)
    }
    
    // MARK: - UI Initial Setup
    
    func setupUI() {
        
        // Label
        lbTitle.text = "安全密碼鎖"
        
        // TextField
        setupPassCodeTextField()
        
        // Button
        setupbtnLogin(buttonTitleColor: .white, buttonBackgroundColor: .systemGray4, buttonEnabled: false)
        
        // vActivityIndicator
        setupvActivityIndicator(isHidden: true) // 按下建立按鈕後，會出現的轉圈過場
    }
    
    private func setupPassCodeTextField() {
        txfPassCode[0].delegate = self
        txfPassCode[1].delegate = self
        txfPassCode[2].delegate = self
        txfPassCode[3].delegate = self
        txfPassCode[4].delegate = self
        txfPassCode[5].delegate = self
        
        txfPassCode[0].layer.borderColor = UIColor.gray.cgColor
        txfPassCode[0].layer.borderWidth = 2
        txfPassCode[0].layer.cornerRadius = txfPassCode[0].bounds.height/10
        txfPassCode[0].tag = 0
        
        txfPassCode[1].layer.borderColor = UIColor.gray.cgColor
        txfPassCode[1].layer.borderWidth = 2
        txfPassCode[1].layer.cornerRadius = txfPassCode[1].bounds.height/10
        txfPassCode[1].tag = 1
        
        txfPassCode[2].layer.borderColor = UIColor.gray.cgColor
        txfPassCode[2].layer.borderWidth = 2
        txfPassCode[2].layer.cornerRadius = txfPassCode[2].bounds.height/10
        txfPassCode[2].tag = 2
        
        txfPassCode[3].layer.borderColor = UIColor.gray.cgColor
        txfPassCode[3].layer.borderWidth = 2
        txfPassCode[3].layer.cornerRadius = txfPassCode[3].bounds.height/10
        txfPassCode[3].tag = 3
        
        txfPassCode[4].layer.borderColor = UIColor.gray.cgColor
        txfPassCode[4].layer.borderWidth = 2
        txfPassCode[4].layer.cornerRadius = txfPassCode[4].bounds.height/10
        txfPassCode[4].tag = 4
        
        txfPassCode[5].layer.borderColor = UIColor.gray.cgColor
        txfPassCode[5].layer.borderWidth = 2
        txfPassCode[5].layer.cornerRadius = txfPassCode[5].bounds.height/10
        txfPassCode[5].tag = 5
    }
    
    /// 設定 UIvActivityIndicator 樣式
    /// - Parameter isHidden: 是否顯示 UIvActivityIndicator，預設為 true
    private func setupvActivityIndicator(isHidden: Bool = true) {
        vActivityIndicator.isHidden = isHidden
    }
    
    /// 設定 `登入按鈕` 的 Button 樣式
    /// - Parameters:
    ///   - buttonTitleColor: Button 文字顏色，預設為 UIColor.white
    ///   - buttonBackgroundColor: Button 背景色，預設為 UIColor.systemGray4
    ///   - buttonEnabled: Button 是否能用，預設為 false
    private func setupbtnLogin(buttonTitleColor: UIColor = .white, buttonBackgroundColor: UIColor = .systemGray4, buttonEnabled: Bool = false) {
        btnLogin.setTitle("登入", for: .normal)
        btnLogin.layer.cornerRadius = btnLogin.bounds.height/6
        btnLogin.backgroundColor = buttonBackgroundColor
        btnLogin.setTitleColor(buttonTitleColor, for: .normal)
        btnLogin.isUserInteractionEnabled = buttonEnabled
    }
    
    // MARK: - IBAction
    
    @IBAction func loginBtnClicked(_ sender: UIButton) {
        print("Code: \(code)")
        if code == UserPreferences.shared.saveNum {
            DispatchQueue.main.async {
                self.btnLogin.isHidden = true
                self.vActivityIndicator.isHidden = false
                self.vActivityIndicator.startAnimating()
                
                let autoVC = AutoFillVC()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    // 取消拖曳返回之前頁面
                    autoVC.isModalInPresentation = true
                    self.present(autoVC, animated: true) {
                        self.vActivityIndicator.stopAnimating()
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: "", message: "輸入密碼不一致", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "OK", style: .default) { action in
                // 清空所有輸入匡裡的值
                for i in 1...self.txfPassCode.count{
                    self.txfPassCode[i-1].text = ""
                }
            }
            alertController.addAction(confirmAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func touchBtnCancel(_ sender: UIBarButtonItem) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
        /*
         // 退回自定義的 UIViewController
         //self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
         */
    }
    
}

// MARK: - UITextFieldDelegate

extension InputPasswordVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text else { return false }
        
        code = "" // 每次輸入時，先將暫存變數重新初始化
        
        // TextField 輸入
        if (textFieldText.count < 1 && string.count > 0) {
            if textField == txfPassCode[0] {
                txfPassCode[1].becomeFirstResponder()
            } else if textField == txfPassCode[1] {
                txfPassCode[2].becomeFirstResponder()
            } else if textField == txfPassCode[2] {
                txfPassCode[3].becomeFirstResponder()
            } else if textField == txfPassCode[3] {
                txfPassCode[4].becomeFirstResponder()
            } else if textField == txfPassCode[4] {
                txfPassCode[5].becomeFirstResponder()
            } else if textField == txfPassCode[5] {
                txfPassCode[5].resignFirstResponder()
            }
            textField.text = string
            
            for i in 0 ... 5 {
                code += txfPassCode[i].text ?? ""
            }
            if code.count == 6 {
                print("登入可用")
                DispatchQueue.main.async {
                    self.setupbtnLogin(buttonBackgroundColor: .purple, buttonEnabled: true)
                }
            } else {
                print("登入不可用")
                DispatchQueue.main.async {
                    self.setupbtnLogin(buttonBackgroundColor: .systemGray4, buttonEnabled: false)
                }
            }
            return false
            
        } else if (textFieldText.count >= 1 && string.count == 0) {
            // TextField 刪除
            if (textField == txfPassCode[1]) {
                txfPassCode[0].becomeFirstResponder()
            } else if(textField == txfPassCode[2]) {
                txfPassCode[1].becomeFirstResponder()
            } else if(textField == txfPassCode[3]) {
                txfPassCode[2].becomeFirstResponder()
            } else if(textField == txfPassCode[4]) {
                txfPassCode[3].becomeFirstResponder()
            } else if(textField == txfPassCode[5]) {
                txfPassCode[4].becomeFirstResponder()
            }
            textField.text = ""
            if code.count < 6 {
                DispatchQueue.main.async {
                    self.setupbtnLogin(buttonBackgroundColor: .systemGray4, buttonEnabled: false)
                }
            }
            return false
            
        } else if (textFieldText.count >= 1) {
            textField.text = string
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.purple.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.gray.cgColor
    }
    
}

// MARK: -
/*
 present 取消拖曳返回之前頁面
 https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E5%95%8F%E9%A1%8C%E8%A7%A3%E7%AD%94%E9%9B%86/ios-13-%E7%9A%84-present-modally-%E8%AE%8A%E6%88%90%E6%9B%B4%E6%96%B9%E4%BE%BF%E7%9A%84%E5%8D%A1%E7%89%87%E8%A8%AD%E8%A8%88-fb6b31f0e20e
 
 */

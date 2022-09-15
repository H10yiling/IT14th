//
//  AutoFillVC.swift
//  AutoFillTest
//
//  Created by 侯懿玲 on 2022/7/6.
//

import UIKit
import AuthenticationServices
/*
 import AuthenticationServices 才能呼叫
 ASCredentialProviderViewController、
 ASExtensionErrorDomain、
 ASExtensionError.userCanceled.rawValue
 */
import SafariServices
import WebKit
// class 的類型一定要是 ASCredentialProviderViewController 才能 cancelRequest、completeRequest
class AutoFillVC: ASCredentialProviderViewController {
    
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var btnAddAccount: UIButton!
    @IBOutlet weak var tvAccountItem: UITableView!
    
    // MARK: - Variables
    
    var passwordListModel = AutoFillArray.shared.autofillArray
    let nextVC = AddAccountVC()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextVC.delegate = self
        
        btnAddAccount.setTitle("", for: .normal)
        
        tvAccountItem.delegate = self
        tvAccountItem.dataSource = self
        tvAccountItem.register(UINib(nibName: "AutoFillTVC", bundle: nil), forCellReuseIdentifier: "AutoFillTVC")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tvAccountItem.reloadData()
    }
    
    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
     */
    
    
    // MARK: - IBAction
    
    @IBAction func touchBtnCancel(_ sender: UIBarButtonItem) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }
    
    @IBAction func touchBtnAddAccount(_ sender: UIButton) {
        let nextVC = AddAccountVC()
        nextVC.delegate = self
        self.present(nextVC, animated: true, completion: nil)
    }
    
    
}

extension AutoFillVC: UITableViewDelegate,UITableViewDataSource {
    
    // UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passwordListModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutoFillTVC.identifier, for: indexPath) as? AutoFillTVC else {
            fatalError("PasswordListTableViewCell 載入失敗")
        }
        cell.titleLabel.text = passwordListModel[indexPath.row].title
        cell.detailLabel.text = passwordListModel[indexPath.row].account
        cell.leftIconImageView.image = UIImage(systemName: "key.fill")!
        return cell
    }
    
    // UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let passwordCredential = ASPasswordCredential(user: passwordListModel[indexPath.row].account, password: passwordListModel[indexPath.row].password)
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
    }
}

// Extension 是為某個 Class 隔離出來的程式區塊
// 設定 AutoFillVC 會遵循 AddAccountProtocol
extension AutoFillVC: AddAccountVCCellItemProtocol {
    func arrayAdd(titleText: String, accountText: String, passwordText: String) {
        passwordListModel.append(PasswordListModel(title: titleText, account: accountText, password: passwordText))
        print("all array: ", passwordListModel)
        tvAccountItem.reloadData()
        print("passwordListModel.count: ",passwordListModel.count)
        //UserPreferences.shared.arrayData = passwordListModel
    }
}

//public extension URL {
//    var urlParameters: [String: String]? {
//        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
//        let queryItems = components.queryItems else { return nil }
//        return queryItems.reduce(into: [String: String]()) { (result, item) in
//            result[item.name] = item.value
//        }
//    }
//}

/*
 // 原生 CredentialProviderViewController 檔案裡的扣
 
 import AuthenticationServices
 
 class CredentialProviderViewController: ASCredentialProviderViewController {
 
 
 /*
  Prepare your UI to list available credentials for the user to choose from. The items in
  'serviceIdentifiers' describe the service the user is logging in to, so your extension can
  prioritize the most relevant credentials in the list.
  */
 override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
 
 }
 
 /*
  Implement this method if your extension supports showing credentials in the QuickType bar.
  When the user selects a credential from your app, this method will be called with the
  ASPasswordCredentialIdentity your app has previously saved to the ASCredentialIdentityStore.
  Provide the password by completing the extension request with the associated ASPasswordCredential.
  If using the credential would require showing custom UI for authenticating the user, cancel
  the request with error code ASExtensionError.userInteractionRequired.
  
  override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
  let databaseIsUnlocked = true
  if (databaseIsUnlocked) {
  let passwordCredential = ASPasswordCredential(user: "j_appleseed", password: "apple1234")
  self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
  } else {
  self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.userInteractionRequired.rawValue))
  }
  }
  */
 
 /*
  Implement this method if provideCredentialWithoutUserInteraction(for:) can fail with
  ASExtensionError.userInteractionRequired. In this case, the system may present your extension's
  UI and call this method. Show appropriate UI for authenticating the user then provide the password
  by completing the extension request with the associated ASPasswordCredential.
  
  override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
  }
  */
 
 @IBAction func cancel(_ sender: AnyObject?) {
 self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
 }
 
 @IBAction func passwordSelected(_ sender: AnyObject?) {
 let passwordCredential = ASPasswordCredential(user: "j_appleseed", password: "apple1234")
 self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
 }
 
 }
 
 */


// MARK: -
/*
 
 https://www.csdn.net/tags/MtjaEgwsODI2OC1ibG9n.html
 
 介紹 autofill 如何建檔
 https://juejin.cn/post/6885176823714414605
 
 
 實施自動填充憑據提供程序擴展
 https://nilotic.github.io/2018/09/07/Implementing-AutoFill-Credential-Provider-Extensions.html
 
 在 iOS 應用程序和擴展程序之間共享信息
 https://rderik.com/blog/sharing-information-between-ios-app-and-an-extension/
 
 */

// MARK: -
/*
 1
 如何在iOS8上以無 Storyboard的方式以程式設計方式建立Today小部件？
 https://www.796t.com/post/MW95NDI=.html
 
 2
 iOS Today App Extension 制作
 https://www.jianshu.com/p/65cc7098371f
 
 */

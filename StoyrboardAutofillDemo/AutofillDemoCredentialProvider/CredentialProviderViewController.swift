//
//  CredentialProviderViewController.swift
//  AutofillDemoCredentialProvider
//
//  Created by 侯懿玲 on 2022/9/10.
//

import AuthenticationServices

struct ListModel: Identifiable {
    
    var id = UUID().uuidString
    
    var account: String         // 帳號
    
    var password: String        // 密碼
}

class CredentialProviderViewController: ASCredentialProviderViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var listTableView: UITableView!
    
    var listArray = [ListModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listArray = [
            ListModel(account: "test01", password: "123"),
            ListModel(account: "test02", password: "456"),
            ListModel(account: "test03", password: "789"),
        ]
    }
    
    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
    */
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
    }
    
    override func prepareInterfaceForExtensionConfiguration() {
        
        let vc = UIViewController(nibName: "XibViewController", bundle: nil)
        
        vc.modalPresentationStyle = .fullScreen // 將 present 的方式改為全螢幕
        
        present(vc, animated: true)
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

    // MARK: - IBAction 取消
    @IBAction func cancel(_ sender: AnyObject?) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier,
                                                       for: indexPath) as? MainTableViewCell
        else {
            fatalError("PasswordListTableViewCell 載入失敗")
        }
        
        cell.accountLabel.text = listArray[indexPath.row].account
        
        cell.passwordLabel.text = listArray[indexPath.row].password
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let passwordCredential = ASPasswordCredential(user: listArray[indexPath.row].account,
                                                      password: listArray[indexPath.row].password)
        
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential,
                                              completionHandler: nil)
    }
}

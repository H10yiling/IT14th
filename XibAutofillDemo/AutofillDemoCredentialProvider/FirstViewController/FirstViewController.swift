//
//  FirstViewController.swift
//  AutofillDemoCredentialProvider
//
//  Created by 侯懿玲 on 2022/9/17.
//

import UIKit
import AuthenticationServices

class FirstViewController: ASCredentialProviderViewController {

    static let identifier = "FirstViewController"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBAction 取消
    @IBAction func cancel(_ sender: AnyObject?) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }
}

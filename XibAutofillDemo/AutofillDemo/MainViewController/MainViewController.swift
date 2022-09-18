//
//  MainViewController.swift
//  AutofillDemo
//
//  Created by 侯懿玲 on 2022/9/10.
//

import UIKit
import AuthenticationServices

class MainViewController: UIViewController {
    
    @IBOutlet weak var autofillStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ASCredentialIdentityStore.shared.getState {state in
            DispatchQueue.main.async {
                self.autofillStatusLabel.text = "是否已啟用自己的 AutofillDemo ?\n\n\(state.isEnabled)"
            }
        }
    }
}

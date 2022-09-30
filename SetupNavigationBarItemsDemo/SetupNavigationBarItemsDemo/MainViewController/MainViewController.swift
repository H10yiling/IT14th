//
//  MainViewController.swift
//  SetupNavigationBarItemsDemo
//
//  Created by 侯懿玲 on 2022/9/29.
//

import UIKit

class MainViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func touchUpInside(_ sender: UIButton) {
        let nextVC = SecondViewController()
        self.pushViewController(nextVC, animated: false)
    }
}

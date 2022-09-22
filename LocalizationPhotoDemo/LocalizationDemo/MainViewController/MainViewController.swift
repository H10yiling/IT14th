//
//  MainViewController.swift
//  LocalizationDemo
//
//  Created by 侯懿玲 on 2022/9/20.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iconImageView.image = UIImage(named: NSLocalizedString("language", comment: ""))
    }
}

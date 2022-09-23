//
//  MainViewController.swift
//  LocalizationDemo
//
//  Created by 侯懿玲 on 2022/9/20.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var baseLabel: UILabel!
    @IBOutlet weak var iconEnglishButton: UIButton!
    @IBOutlet weak var iconChineseButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        iconEnglishButton.setTitle("English", for: .normal)
        iconChineseButton.setTitle("Chinese", for: .normal)
    
    }
    
    @IBAction func pushToLanguagePage(_ sender: UIButton) {
        switch sender{
        case iconEnglishButton:
            let nextVC = EnglishViewController()
            self.navigationController?.pushViewController(nextVC, animated: false)
        case iconChineseButton:
            let nextVC = ChineseViewController()
            self.navigationController?.pushViewController(nextVC, animated: false)
        default:
            break
        }
    }
}

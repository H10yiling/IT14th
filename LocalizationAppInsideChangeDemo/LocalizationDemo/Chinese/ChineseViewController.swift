//
//  ChineseViewController.swift
//  LocalizationDemo
//
//  Created by 侯懿玲 on 2022/9/23.
//

import UIKit

class ChineseViewController: UIViewController {

    @IBOutlet weak var chineseLabel: UILabel!
    @IBOutlet weak var iconChineseImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chineseLabel.text = Localize.shared.localizedText(withText: "language", withLocalizationFileNmae: "zh-Hant")
        iconChineseImageView.image = Localize.shared.localizedImage(withImageName: "Chinese", withLocalizationFileNmae: "zh-Hant")
    }
}

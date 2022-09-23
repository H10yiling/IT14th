//
//  EnglishViewController.swift
//  LocalizationDemo
//
//  Created by 侯懿玲 on 2022/9/23.
//

import UIKit

class EnglishViewController: UIViewController {

    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var iconEnglishImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        englishLabel.text = Localize.shared.localizedText(withText: "language", withLocalizationFileNmae: "en")
        iconEnglishImageView.image = Localize.shared.localizedImage(withImageName: "English", withLocalizationFileNmae: "en")
    }
}

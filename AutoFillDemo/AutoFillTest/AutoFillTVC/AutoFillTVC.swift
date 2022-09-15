//
//  AutoFillTVC.swift
//  AutoFillTest
//
//  Created by 侯懿玲 on 2022/7/6.
//

import UIKit

class AutoFillTVC: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    static let identifier = "AutoFillTVC"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setInit(title: String, detail: String, icon: UIImage) {
        titleLabel.text = title
        detailLabel.text = detail
        leftIconImageView.image = icon
    }
}

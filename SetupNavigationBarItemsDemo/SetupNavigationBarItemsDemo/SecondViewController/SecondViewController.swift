//
//  SecondViewController.swift
//  SetupNavigationBarItemsDemo
//
//  Created by 侯懿玲 on 2022/9/29.
//

import UIKit

class SecondViewController: BaseViewController {

    @IBOutlet weak var numLabel: UILabel!
    
    var index = UserPreferences.shared.numIndex
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Initial Setup
    
    func setupUI() {
        setupLeftAndRightNavigationBarItems()
        numLabel.text = index
    }
    
    // MARK: - 客製化 NavigationBar
    
    /// CustomizationNavigationBarItems
    /// - Parameters:
    ///   - LeftNavigationBarItems: 返回鍵
    ///   - RightNavigationBarItems: 加1、減1、歸零
    private func setupLeftAndRightNavigationBarItems() {
        
        // MARK: - Left NavigationBarItems 由左至右
        
        let backButton = UIButton(type: .system)
        
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        
        backButton.setTitle("返回鍵", for: .normal)
        
        // 新增返回鍵被點擊後的觸發事件
        backButton.addTarget(self, action: #selector(self.backButtonAction), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        // MARK: - Right NavigationBarItems 由右至左
        
        let valuePlus = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(valuePlusOneObjc))
        
        let valueMinus = UIBarButtonItem(image: UIImage(systemName: "minus"),
                                         style: .done,
                                         target: self,
                                         action: #selector(valueMinusOneObjc))
        
        let valueZero = UIBarButtonItem(image: UIImage(systemName: "clear"),
                                        style: .done,
                                        target: self,
                                        action: #selector(valueToZeroObjc))
        
        self.navigationItem.rightBarButtonItems = [valuePlus, valueMinus, valueZero]
    }
    
    /// 數值運算
    private func valueChange(calculation: String){
        
        switch calculation{
        
        /// 數值加一
        case "plus":
            index = "\(Int(index)! + 1)"
            numLabel.text = index
            UserPreferences.shared.numIndex = index
            
        /// 數值減一
        case "minus":
            index = "\(Int(index)! - 1)"
            numLabel.text = index
            UserPreferences.shared.numIndex = index
            
        /// 數值歸零
        case "clear":
            index = "0"
            numLabel.text = index
            UserPreferences.shared.numIndex = index
            
        default:
            break
        }
    }
    
    // MARK: - Right NavigationBarItems Function
    
    @objc func backButtonAction() {
        popViewController(false)
    }
    
    @objc func valuePlusOneObjc() {
        valueChange(calculation: "plus")
    }
    
    @objc func valueMinusOneObjc() {
        valueChange(calculation: "minus")
    }
    
    @objc func valueToZeroObjc() {
        valueChange(calculation: "clear")
    }
}

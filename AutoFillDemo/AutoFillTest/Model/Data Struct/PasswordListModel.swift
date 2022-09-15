//
//  PasswordListModel.swift
//  AutoFillTest
//
//  Created by 侯懿玲 on 2022/8/1.
//

import Foundation

struct PasswordListModel: Identifiable {
    
    var id = UUID().uuidString
    
    var title: String
    
    var account: String
    
    var password: String
}

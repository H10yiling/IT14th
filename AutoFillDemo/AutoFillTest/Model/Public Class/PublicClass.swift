//
//  PublicClass.swift
//  AutoFillTest
//
//  Created by 侯懿玲 on 2022/8/1.
//

class AutoFillArray {
    
    static let shared = AutoFillArray()
    
    // 這邊未來會改成撈資料庫資料
    var autofillArray: [PasswordListModel] =
    [
        PasswordListModel(title: "5music", account: "zaqxsw0218", password: "zaqxsw0218"),
        PasswordListModel(title: "5music", account: "zaqxsw0219", password: "0219"),
        PasswordListModel(title: "5music", account: "zaqxsw0220", password: "0220")
    ]
}

class IdAndURLText {
    static let shared = IdAndURLText()
    var text = String()
}

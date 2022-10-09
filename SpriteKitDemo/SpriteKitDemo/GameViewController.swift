//
//  GameViewController.swift
//  SpriteKitDemo
//
//  Created by 侯懿玲 on 2022/10/10.
//

import UIKit
import SpriteKit    // 創建遊戲和其他圖形密集型應用程序，在二維中繪製形狀、粒子、文本、圖像和視頻
import GameplayKit  // 融入常見的遊戲行為，例如隨機數生成、人工智能、尋路和代理行為。

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            // 從 "GameScene.sks" 加载 "SKScene"
            if let scene = SKScene(fileNamed: "GameScene") {
                
                // 將縮放模式設置為適合裝置的縮放比例
                scene.scaleMode = .aspectFill
                
                // 呈現場景
                view.presentScene(scene)
            }
            
            // 忽略遍歷順序，需要在場景中使用 zPosition，以正確保證元素在彼此的前面或後面
            view.ignoresSiblingOrder = true
            
            // 顯示性能統計信息(fps、nodes)
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    // 是否自動旋轉
    override var shouldAutorotate: Bool {
        return true
    }

    // UI 界面的遮罩
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        // 使用者介面
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    // 狀態欄隱藏
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

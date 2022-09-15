//
//  SceneDelegate.swift
//  AutoFillDemo
//
//  Created by 侯懿玲 on 2022/7/5.
//

import UIKit
import AuthenticationServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 進入 Application 的第一個 ViewController
        let rootViewController = MainVC(nibName: String(describing: MainVC.self), bundle: nil)
        
        // 設定 NavigationController
        let navigationViewController = UINavigationController(rootViewController: rootViewController)
        
        // NavigationBar 開關
        navigationViewController.isNavigationBarHidden = true
        
        window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene
        window?.rootViewController = navigationViewController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("in fg")
        ASCredentialIdentityStore.shared.getState { state in
            if state.isEnabled {
                NotificationCenter.default.post(name: Notification.Name("statusAutofill"), object: nil, userInfo: ["status": true])
            }
            else {
                NotificationCenter.default.post(name: Notification.Name("statusAutofill"), object: nil, userInfo: ["status": false])
            }
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print("in bg")
        ASCredentialIdentityStore.shared.getState { state in
            if state.isEnabled {
                NotificationCenter.default.post(name: Notification.Name("statusAutofill"), object: nil, userInfo: ["status": true])
            }
            else {
                NotificationCenter.default.post(name: Notification.Name("statusAutofill"), object: nil, userInfo: ["status": false])
            }
        }
    }
    
}


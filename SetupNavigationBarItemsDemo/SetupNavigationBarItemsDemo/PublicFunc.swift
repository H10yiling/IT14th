//
//  PublicFunc.swift
//  SetupNavigationBarItemsDemo
//
//  Created by 侯懿玲 on 2022/9/29.
//

import Foundation
import UIKit
class BaseViewController: UIViewController {

    // MARK: - NavigationController.push
    
    /// NavigationController.pushViewController 跳頁 (不帶 Closure)
    /// - Parameters:
    ///   - viewController: 要跳頁到的 UIViewController
    ///   - animated: 是否要換頁動畫，預設為 true
    public func pushViewController(_ viewController: UIViewController, animated: Bool = true) {
        if let navigationController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: animated)
        }
    }
    
    /// NavigationController.pushViewController 跳頁 (帶 Closure)
    /// - Parameters:
    ///   - viewController: 要跳頁到的 UIViewController
    ///   - animated: 是否要換頁動畫
    ///   - completion: 換頁過程中，要做的事
    public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        self.navigationController?.pushViewController(viewController, animated: animated)
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    // MARK: - NavigationController.pop
    
    /// NavigationController.popViewController 回上一頁 (不帶 Closure)
    /// - Parameters:
    ///   - animated: 是否要換頁動畫，預設為 true
    public func popViewController(_ animated: Bool = true) {
        self.navigationController?.popViewController(animated: animated)
    }
    
    /// NavigationController.popViewController 回上一頁 (帶 Closure)
    /// - Parameters:
    ///   - animated: 是否要換頁動畫
    ///   - completion: 換頁過程中，要做的事
    public func popViewController(animated: Bool, completion: @escaping () -> Void) {
        self.navigationController?.popViewController(animated: animated)
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
}

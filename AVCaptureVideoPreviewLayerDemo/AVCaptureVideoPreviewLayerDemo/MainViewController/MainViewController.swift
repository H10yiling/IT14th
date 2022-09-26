//
//  MainViewController.swift
//  AVCaptureVideoPreviewLayerDemo
//
//  Created by 侯懿玲 on 2022/9/26.
//

import UIKit
import AVFoundation // 控制視聽設備、相機、影音等

class MainViewController: UIViewController {
    
    @IBOutlet var scanQRCodeView: UIView!
    
    var captureSession:AVCaptureSession?                        // 用於捕捉視訊及音訊，協調視訊及音訊的輸入及輸出
    var captureVideoPreviewLayer:AVCaptureVideoPreviewLayer!    // 呈現Session捕捉的資料
    var qrcodeString:String!                                    // QRcode 讀取到的字串
    
    var tempPath = UIBezierPath()
    
    var blackBackgroundView = UIView()                          // 灰色遮罩
    let superViewBounds = UIScreen.main.bounds                  // 裝置的邊界大小
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //blackView()
        scanQRCode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        captureSession?.commitConfiguration()
        // 判斷 AVCaptureSession 的接收器是否正在執行
        if (captureSession?.isRunning == false) {
            captureSession?.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession?.stopRunning()
        }
    }
    
    // iOS 11 後新API，根視圖的邊距變更時會觸發該方法的回調
    override func viewLayoutMarginsDidChange(){
        blackView()
    }
    
    private func blackView(){
        let width = superViewBounds.width / 2
        let newX = superViewBounds.width / 2 - (width / 2)
        let newY = superViewBounds.height / 2 - (width / 1.5)
        tempPath = UIBezierPath(roundedRect: CGRect(x: newX, y: newY, width: width, height: width),
                                    cornerRadius: width / 10)
        //print("-----superViewBounds, width, newX, newY, tempPath", superViewBounds, width, newX, newY, tempPath)
        //-----superViewBounds, width, newX, newY, tempPath (0.0, 0.0, 375.0, 812.0) 187.5 93.75 281.0 <UIBezierPath: 0x281e2c900; <MoveTo {122.41246875, 281}>
        
        blackBackgroundView = UIView(frame: UIScreen.main.bounds)
        blackBackgroundView.backgroundColor = UIColor.black
        blackBackgroundView.alpha = 0.6
        blackBackgroundView.layer.mask = addTransparencyView(tempPath: tempPath) // 只有遮罩層覆蓋的地方才會顯示出來
        print("1234567890",tempPath.bounds) //(93.75, 281.0, 187.5, 187.5)
        blackBackgroundView.layer.name = "blackBackgroundView"
        scanQRCodeView.addSubview(blackBackgroundView)
    }
    
    // MARK: - Left NavigationBarItems Function
    /// 客製化 NavigationBar
    /// - Parameters:
    ///   - leftBarButtonItem: 返回鍵
    ///   - rightBarButtonItem: 儲存鍵
    private func customizedNavigationBarItems() {
        // 返回鍵
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)                     // btn image
        backButton.tintColor = .white                                                              // btn color
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)            // set to left navigationBar
        backButton.addTarget(self, action: #selector(self.backButtonAction), for: .touchUpInside)  // 新增返回鍵被點擊後的觸發事件
    }
    
    // MARK: - Left NavigationBarItems Function
    
    /// 按下退回按鈕後要做的事 ...
    @objc func backButtonAction() {
        self.popViewController(false)
        print("backkkkkkkk")
    }
    
    // #1 摳圖
    func addTransparencyView(tempPath: UIBezierPath?) -> CAShapeLayer? {
        let path = UIBezierPath(rect: UIScreen.main.bounds)
        if let tempPath = tempPath {
            path.append(tempPath)
        }
        path.usesEvenOddFillRule = true
        print(path)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.black.cgColor // 其他颜色都可以，只要不是透明的
        shapeLayer.fillRule = .evenOdd
        return shapeLayer
    }
}

// 用來捕捉並輸出數據的方法
extension MainViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    /// 設定AVCaptureSession
    func scanQRCode() {
        customizedNavigationBarItems()
        
        // black Background frame
        scanQRCodeView.frame = UIScreen.main.bounds
        
        // 實例化一個 AVCaptureSession 物件
        captureSession = AVCaptureSession()
        
        // 透過 AVCaptureDevice 來捕捉相機及其相關屬性
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        let videoInput:AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print(error)
            return
        }
        
        // 判斷是否可以將 videoInput 加入到 captureSession
        if (captureSession?.canAddInput(videoInput) ?? false) {
            captureSession?.addInput(videoInput)
        } else {
            return
        }
        
        // 實例化一個 AVCaptureMetadataOutput 物件
        let metaDataOutput = AVCaptureMetadataOutput()
        
        // 透過 AVCaptureMetadataOutput 輸出資料
        // 判斷是否可以將 metaDataOutput 輸出到 captureSession
        if (captureSession?.canAddOutput(metaDataOutput) ?? false) {
            captureSession?.addOutput(metaDataOutput)
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main) //執行處理 QRCode
            metaDataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417] // 設定可以處理哪些類型的條碼
            //CGRect(x: 93.75, y: 281.0, width: 187.5, height: 187.5)
//            let x = 93.75/480
//            let y = 281.0/640
//            let width = 187.5/480
//            let height = 187.5/640
//            metaDataOutput.rectOfInterest = CGRect(x: x, y: y, width: width, height: height)
            
        } else {
            return
        }
        
        // 用 AVCaptureVideoPreviewLayer 來呈現 AVCaptureSession 的資料
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        captureVideoPreviewLayer.videoGravity = .resizeAspectFill
        captureVideoPreviewLayer.frame = scanQRCodeView.layer.frame
        //tempPath.bounds
        scanQRCodeView.layer.addSublayer(captureVideoPreviewLayer)
        captureSession?.startRunning()
    }
    
    
    // 使用 AVCaptureMetadataOutput 物件辨識 QRCode
    // AVCaptureMetadataOutputObjectsDelegate 裡的委派方法 metadataOutout 會被呼叫
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            // AVMetadataMachineReadableCodeObject 是從 Output 擷取到 Barcode 的內容
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            
            // 顯示掃描到的QRCode打個框框讓使用者知道
            //let qrCodeObject = captureVideoPreviewLayer?.transformedMetadataObject(for: readableObject)
            
            for subView in scanQRCodeView.subviews{
                if subView.layer.name == "blackBackgroundView" {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        subView.alpha = 0 // 不透明
                    }) { (bool) in
                        subView.removeFromSuperview()
                        // 將讀取到的內容轉成字串
                        guard let stringValue = readableObject.stringValue else { return }
                        self.qrcodeString = stringValue
                        // 將讀取到的字顯示出來
                        // print("- - - - - - qrCodeObject: ", self.qrcodeString)
                        
                        self.showAlertWith(title: "", message: "\(self.qrcodeString.description)", vc: self, confirmTitle: "Yes", cancelTitle: "No", confirm: {
                            // 開啟連結
                            if let url = URL(string: self.qrcodeString) {
                                if self.qrcodeString.contains("http") || self.qrcodeString.contains("https") {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                                else {
                                    let newURL = URL(string: "https://\(self.qrcodeString.description)")
                                    UIApplication.shared.open(newURL!, options: [:], completionHandler: nil)
                                }
                            }
                        }, cancel: {[self] in
                            blackView()
                        })
                        //self.navigationController?.popViewController(animated: true)
                    }
                }
                else{
                    self.scanQRCode()
                }
            }
        }
    }
}

// MARK: - NavigationController
extension MainViewController{
    
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
    
    /// NavigationController.popToViewController 回到指定 ViewController (不帶 Closure)
    /// - Parameters:
    ///   - currectVC: 目前所在的 ViewController
    ///   - popVC_index: 在 NavigationController.viewControllers 中，指定 ViewController 的 index
    ///   - animated: 是否要換頁動畫，預設為 true
    public func popToViewController(currectVC viewController: UIViewController, popVC_index: Int, animated: Bool = true) {
        guard let currectVC_index = navigationController?.viewControllers.firstIndex(of: self) else { return }
        if let vc = navigationController?.viewControllers[currectVC_index - popVC_index] {
            self.navigationController?.popToViewController(vc, animated: animated)
        }
    }
    
    /// NavigationController.popToViewController 回到指定 ViewController (帶 Closure)
    /// - Parameters:
    ///   - currectVC: 目前所在的 ViewController
    ///   - popVC_index: 在 NavigationController.viewControllers 中，指定 ViewController 的 index
    ///   - animated: 是否要換頁動畫
    ///   - completion: 換頁過程中，要做的事
    public func popToViewController(currectVC viewController: UIViewController, popVC_index: Int, animated: Bool, completion: @escaping () -> Void) {
        guard let currectVC_index = navigationController?.viewControllers.firstIndex(of: self) else { return }
        if let vc = navigationController?.viewControllers[currectVC_index - popVC_index] {
            self.navigationController?.popToViewController(vc, animated: animated)
        }
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    /// NavigationController.popToRootViewController 回到 Root ViewController
    /// - Parameters:
    ///   - animated: 是否要換頁動畫，預設為 true
    public func popToRootViewController(_ animated: Bool = true) {
        self.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// 單一按鈕 Alert
    /// - Parameters:
    ///   - title: Alert 的標題
    ///   - message: Alert 的訊息
    ///   - vc: 要在哪個畫面跳出來
    ///   - confirmTitle: 按鈕的文字
    ///   - confirm: 按下按鈕後要做的事
    public func showAlertWith(title: String?, message: String?, vc: UIViewController, confirmTitle: String, confirm: (() -> Void)?) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { action in
                confirm?()
            }
            alertController.addAction(confirmAction)
            vc.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// 確認、取消按鈕的 Alert
    /// - Parameters:
    ///   - title: Alert 的標題
    ///   - message: Alert 的訊息
    ///   - vc: 要在哪個畫面跳出來
    ///   - confirmTitle: 確認按鈕的文字
    ///   - cancelTitle: 取消按鈕的文字
    ///   - confirm: 按下確認按鈕後要做的事
    ///   - cancel: 按下取消按鈕後要做的事
    public func showAlertWith(title: String?, message: String?, vc: UIViewController, confirmTitle: String, cancelTitle: String, confirm: (() -> Void)?, cancel: (() -> Void)?) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { action in
                confirm?()
            }
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
                cancel?()
            }
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            vc.present(alertController, animated: true, completion: nil)
        }
    }
}


// MARK: - 參考資料
/*
 
 #1: func addTransparencyView(tempPath: UIBezierPath?) -> CAShapeLayer?
 https://www.niwoxuexi.com/blog/littleGG/article/447
 
 CAShapeLayer & UIBezierPath:
 
 UIBezierPath: 屬於路徑
 意味著我們使用UIBezierPath來繪出我們想要的形狀，但此時所繪出的圖案屬「圖案」，所以無法對其進行操作（像是動畫操作、移動、操縱或其他操作）
 
 CAShapeLayer: 屬於向量繪製圖層
 因此可以被填充、觸碰，或是對他線條進行調整操作，並且人員可以在圖層上添加動畫特效，創造吸引人的動畫效果。
 
 https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E6%95%99%E5%AE%A4/cashapelayer-uibezierpath-2b2618b98b6c
 */


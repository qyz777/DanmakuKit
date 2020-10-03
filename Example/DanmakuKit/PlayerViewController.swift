//
//  PlayerViewController.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2020/10/1.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import DanmakuKit

//MARK: PlayerViewController

class PlayerViewController: UIViewController {
    
    private weak var originalWindow: UIWindow?
    
    private var originalFrame: CGRect = .zero
    
    private weak var originalParent: UIViewController?
    
    private var fullScreenWindow: UIWindow?
    
    private var lastOrientation: UIDeviceOrientation = .portrait
    
    public private(set) var isFullScreen: Bool = false
    
    public var danmakuArray: [DanmakuTextCellModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(playr)
        playr.frame = view.bounds
        
        view.addSubview(danmakuView)
        danmakuView.frame = view.bounds
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        danmakuService.request { [weak self] (json) in
            guard let strongSelf = self else { return }
            strongSelf.danmakuArray = json["data"].arrayValue.map({ (json) -> DanmakuTextCellModel in
                return DanmakuTextCellModel(json: json)
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playr.frame = view.bounds
        danmakuView.frame = view.bounds
        danmakuView.recaculateTracks()
    }
    
    //MARK: Notification
    
    @objc
    func deviceOrientationDidChange(_ notification: Notification) {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            enterFullScreen()
        } else {
            leaveFullScreen()
        }
        lastOrientation = UIDevice.current.orientation
    }
    
    //MARK: Private
    
    private func enterFullScreen() {
        guard !isFullScreen else { return }
        originalFrame = view.frame
        originalParent = parent
        originalWindow = UIApplication.shared.delegate?.window as? UIWindow
        let rootViewController = FullScreenViewController()
        fullScreenWindow = UIWindow(frame: UIScreen.main.bounds)
        fullScreenWindow?.rootViewController = rootViewController
        fullScreenWindow?.makeKeyAndVisible()
        
        let angle = UIDevice.current.orientation == .landscapeLeft ? CGFloat.pi / 2 : -CGFloat.pi / 2
        
        UIView.animate(withDuration: 0.35, animations: {
            self.view.transform = CGAffineTransform(rotationAngle: angle)
            self.view.frame = CGRect(x: 0, y: 0, width: rootViewController.view.bounds.height, height: rootViewController.view.bounds.width)
        }) { (flag) in
            self.detach()
            self.attach(viewController: rootViewController)
            self.view.transform = .identity
            self.view.frame = rootViewController.view.bounds
            self.view.setNeedsLayout()
            self.danmakuView.recaculateTracks()
            self.isFullScreen = true
        }
    }
    
    private func leaveFullScreen() {
        guard isFullScreen else { return }
        guard let originalParent = originalParent else { return }
        
        let superViewWidth = view.superview?.bounds.width ?? .zero
        let superViewHeight = view.superview?.bounds.height ?? .zero
        let convertOrigin = parent?.view.convert(originalFrame.origin, to: view.superview) ?? .zero
        let origin = lastOrientation == .landscapeLeft ? CGPoint(x: convertOrigin.y, y: convertOrigin.x) : CGPoint(x: superViewWidth - convertOrigin.y - originalFrame.height
            , y: superViewHeight - convertOrigin.x - originalFrame.width)
        let angle = lastOrientation == .landscapeLeft ? -CGFloat.pi / 2 : CGFloat.pi / 2
        
        UIView.animate(withDuration: 0.35, animations: {
            self.view.transform = CGAffineTransform(rotationAngle: angle)
            self.view.frame = CGRect(x: origin.x, y: origin.y, width: self.originalFrame.height, height: self.originalFrame.width)
        }) { (flag) in
            self.detach()
            self.attach(viewController: originalParent)
            self.view.transform = .identity
            self.view.frame = self.originalFrame
            self.view.setNeedsLayout()
            self.danmakuView.recaculateTracks()
            self.isFullScreen = false
            self.originalWindow?.makeKeyAndVisible()
            self.originalParent = nil
            self.fullScreenWindow = nil
        }
    }
    
    //MARK: Getter
    
    public lazy var playr: PlayerView = {
        let p = PlayerView()
        p.delegate = self
        return p
    }()
    
    private lazy var danmakuService: DanmakuService = {
        let s = DanmakuService()
        return s
    }()
    
    private lazy var danmakuView: DanmakuView = {
        let danmakuView = DanmakuView(frame: view.bounds)
        return danmakuView
    }()

}

extension PlayerViewController {
    
    func setup(url: URL) {
        playr.setup(url: url)
    }
    
    func play() {
        playr.play()
    }
    
    func pause() {
        playr.pause()
    }
    
    func stop() {
        playr.stop()
    }
    
    func attach(viewController: UIViewController) {
        viewController.addChild(self)
        viewController.view.addSubview(view)
        didMove(toParent: viewController)
    }
    
    func detach() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
}

extension PlayerViewController: PlayerViewDelegate {
    
    func player(_ player: PlayerView, playAt time: Double) {
        var array: [DanmakuTextCellModel] = []
        for cm in danmakuArray {
            if cm.offsetTime <= time {
                array.append(cm)
            } else {
                break
            }
        }
        danmakuArray.removeFirst(array.count)
        array.forEach {
            $0.calculateSize()
            danmakuView.shoot(danmaku: $0)
        }
    }
    
    func player(_ player: PlayerView, statusDidChange status: PlayerViewStatus) {
        switch status {
        case .playing:
            danmakuView.play()
        case .pause:
            danmakuView.pause()
        case .stop, .error, .unknown:
            danmakuView.stop()
        }
    }
    
}

//MARK: FullScreenViewController

fileprivate class FullScreenViewController: UIViewController {
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
}


extension UIViewController {
    
    static func visibleViewController() -> UIViewController? {
        guard var current = UIApplication.shared.delegate?.window??.rootViewController else { return nil }
        
        while true {
            if current.presentedViewController != nil {
                current = current.presentedViewController!
            } else {
                if current.isKind(of: UINavigationController.self) {
                    let nav = (current as! UINavigationController)
                    if nav.visibleViewController != nil {
                        current = nav.visibleViewController!
                    } else {
                        current = nav
                    }
                } else if current.isKind(of: UITabBarController.self) {
                    let tabBar = (current as! UITabBarController)
                    if tabBar.selectedViewController != nil {
                        current = tabBar.selectedViewController!
                    } else {
                        current = tabBar
                    }
                } else {
                    break
                }
            }
        }
        
        return current
    }
    
}

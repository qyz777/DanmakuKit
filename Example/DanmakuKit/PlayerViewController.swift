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
    
    public var danmakuArray: [AnyObject & DanmakuCellModel & TestDanmakuCellModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(playr)
        view.addSubview(coverView)
        coverView.addSubview(scaleButton)
        coverView.addSubview(playButton)
        coverView.addSubview(pauseButton)
        view.addSubview(danmakuView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPlayer))
        view.addGestureRecognizer(tap)
        
        danmakuService.request { [weak self] (json) in
            guard let strongSelf = self else { return }
            strongSelf.danmakuArray = json["data"].arrayValue.map({ (json) -> AnyObject & DanmakuCellModel & TestDanmakuCellModel in
                if json["danmaku_type"].int == 1 {
                    return DanmakuTestGifCellModel(json: json)
                } else {
                    return DanmakuTextCellModel(json: json)
                }
            })
        }
        
        showCoverView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playr.frame = view.bounds
        danmakuView.frame = view.bounds
        coverView.frame = view.bounds
        danmakuView.recaculateTracks()
        
        scaleButton.bounds.size = CGSize(width: 40, height: 40)
        scaleButton.frame.origin = CGPoint(x: coverView.bounds.width - scaleButton.bounds.width - 15, y: coverView.bounds.height - scaleButton.bounds.height - 15)
        
        playButton.sizeToFit()
        playButton.center = CGPoint(x: coverView.bounds.width / 2.0, y: coverView.bounds.height / 2.0)
        
        pauseButton.sizeToFit()
        pauseButton.center = CGPoint(x: coverView.bounds.width / 2.0, y: coverView.bounds.height / 2.0)
    }
    
    //MARK: Action
    
    @objc
    func didTapPlayer() {
        showCoverView()
    }
    
    @objc
    func didClickScaleButton() {
        if isFullScreen {
            leaveFullScreen()
            lastOrientation = UIDevice.current.orientation == .portrait ? .landscapeRight : UIDevice.current.orientation
        } else {
            enterFullScreen()
            lastOrientation = .landscapeLeft
        }
    }
    
    @objc
    func didClickPlayButton() {
        play()
        hideCoverViewAfterDelay()
    }
    
    @objc
    func didClickPauseButton() {
        pause()
        hideCoverViewAfterDelay()
    }
    
    @objc
    func hideCoverView() {
        coverView.alpha = 1
        UIView.animate(withDuration: 0.25, animations: {
            self.coverView.alpha = 0
        }) { (flag) in
            self.coverView.alpha = 1
            self.coverView.isHidden = true
        }
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
        
        let angle = UIDevice.current.orientation == .landscapeRight ? -CGFloat.pi / 2 : CGFloat.pi / 2
        
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
        let angle = lastOrientation == .landscapeRight ? CGFloat.pi / 2 : -CGFloat.pi / 2
        
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
    
    private func showCoverView() {
        hideCoverViewAfterDelay()
        guard coverView.isHidden else { return }
        coverView.alpha = 0
        coverView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.coverView.alpha = 1
        }
    }
    
    private func hideCoverViewAfterDelay() {
        NSObject.cancelPreviousPerformRequests(withTarget: self
        , selector: #selector(hideCoverView), object: nil)
        perform(#selector(hideCoverView), with: nil, afterDelay: 3, inModes: [.common])
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
    
    private lazy var scaleButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "player_scale"), for: .normal)
        view.addTarget(self, action: #selector(didClickScaleButton), for: .touchUpInside)
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var coverView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "player_play"), for: .normal)
        view.addTarget(self, action: #selector(didClickPlayButton), for: .touchUpInside)
        return view
    }()
    
    private lazy var pauseButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "player_pause"), for: .normal)
        view.addTarget(self, action: #selector(didClickPauseButton), for: .touchUpInside)
        view.isHidden = true
        return view
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
        var array: [AnyObject & DanmakuCellModel & TestDanmakuCellModel] = []
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
            playButton.isHidden = true
            pauseButton.isHidden = false
        case .pause:
            danmakuView.pause()
            playButton.isHidden = false
            pauseButton.isHidden = true
        case .stop, .error, .unknown:
            danmakuView.stop()
            playButton.isHidden = false
            pauseButton.isHidden = true
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

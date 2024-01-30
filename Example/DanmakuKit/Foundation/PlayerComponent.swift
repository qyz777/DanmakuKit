//
//  PlayerComponent.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2023/3/5.
//

import UIKit

protocol PlayerComponent: Component {
    
    func viewDidLoad()
    
    func viewWillAppear(_ animated: Bool)
    
    func viewDidAppear(_ animated: Bool)
    
    func viewWillDisappear(_ animated: Bool)
    
    func viewDidDisappear(_ animated: Bool)
    
    func appDidEnterBackground()
    
    func appDidBecomeActive()
    
    func appWillEnterForeground()
    
    func appWillResignActive()
    
    func layoutSubviews()
    
    func orientationDidChange(_ orientation: UIDeviceOrientation)
    
}

extension PlayerComponent {
    
    func viewDidLoad() {}
    
    func viewWillAppear(_ animated: Bool) {}
    
    func viewDidAppear(_ animated: Bool) {}
    
    func viewWillDisappear(_ animated: Bool) {}
    
    func viewDidDisappear(_ animated: Bool) {}
    
    func appDidEnterBackground() {}
    
    func appDidBecomeActive() {}
    
    func appWillEnterForeground() {}
    
    func appWillResignActive() {}
    
    func layoutSubviews() {}
    
    func orientationDidChange(_ orientation: UIDeviceOrientation) {}
    
}

class PlayerComponentCenter: ComponentCenter {
    
    private var playerComponents: [PlayerComponent] = []
    
    override var components: [Component] {
        get {
            return playerComponents
        }
        set {
            guard let v = newValue as? [PlayerComponent] else  {
                return
            }
            playerComponents = v
        }
    }
    
    func viewDidLoad() {
        playerComponents.forEach { $0.viewDidLoad() }
    }
    
    func viewWillAppear(_ animated: Bool) {
        playerComponents.forEach { $0.viewWillAppear(animated) }
    }
    
    func viewDidAppear(_ animated: Bool) {
        playerComponents.forEach { $0.viewDidAppear(animated) }
    }
    
    func viewWillDisappear(_ animated: Bool) {
        playerComponents.forEach { $0.viewWillDisappear(animated) }
    }
    
    func viewDidDisappear(_ animated: Bool) {
        playerComponents.forEach { $0.viewDidDisappear(animated) }
    }
    
    func appDidEnterBackground() {
        playerComponents.forEach { $0.appDidEnterBackground() }
    }
    
    func appDidBecomeActive() {
        playerComponents.forEach { $0.appDidBecomeActive() }
    }
    
    func appWillEnterForeground() {
        playerComponents.forEach { $0.appWillEnterForeground() }
    }
    
    func appWillResignActive() {
        playerComponents.forEach { $0.appWillResignActive() }
    }
    
    func layoutSubviews() {
        playerComponents.forEach { $0.layoutSubviews() }
    }
    
    func orientationDidChange(_ orientation: UIDeviceOrientation) {
        playerComponents.forEach { $0.orientationDidChange(orientation) }
    }
    
}

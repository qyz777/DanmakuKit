//
//  PlayerDemoViewController.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2020/10/1.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import DeviceKit

class PlayerDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupPlayerViewController()
        
        if let url = Bundle.main.url(forResource: "demo", withExtension: "MOV") {
            playerViewController.setup(url: url)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerViewController.stop()
    }
    
    private func setupPlayerViewController() {
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
        
        playerViewController.view.frame = CGRect(x: 0, y: Device.isXSeries ? 84 : 64 + 100, width: UIScreen.main.bounds.width, height: 211)
    }
    
    lazy var playerViewController: PlayerViewController = {
        let vc = PlayerViewController()
        return vc
    }()

}


extension Device {
    
    static var isXSeries: Bool {
        return Device.allDevicesWithSensorHousing.contains(Device.current)
    }
    
}

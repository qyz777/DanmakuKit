//
//  FunctionDemoViewController.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2020/8/30.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import DanmakuKit

class FunctionDemoViewController: UIViewController {
    
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(danmakuView)
        view.addSubview(playButton)
        view.addSubview(pauseButton)
        view.addSubview(stopButton)
        danmakuView.frame.origin.y = 100
        playButton.sizeToFit()
        pauseButton.sizeToFit()
        stopButton.sizeToFit()
        
        playButton.center.x = SCREEN_WIDTH / 2.0
        playButton.frame.origin.y = 500
        
        pauseButton.center.x = SCREEN_WIDTH / 2.0
        pauseButton.frame.origin.y = 530
        
        stopButton.center.x = SCREEN_WIDTH / 2.0
        stopButton.frame.origin.y = 560
    }
    
    private let contents: [String] = [
        "我是一条长长的弹幕",
        "我是测试",
        "测试一条弹幕",
        "😈😈😈😈😈😈😈😈😈😈"
    ]
    
    @objc
    func sendDanmaku() {
        let index = randomIntNumber(lower: 0, upper: contents.count)
        let cellModel = DanmakuTextCellModel()
        cellModel.text = contents[index]
        danmakuView.shoot(danmaku: cellModel)
    }
    
    @objc
    func play() {
        if timer == nil {
            timer = Timer(timeInterval: 0.3, target: self, selector: #selector(sendDanmaku), userInfo: nil, repeats: true)
        }
        guard let timer = timer else { return }
        RunLoop.main.add(timer, forMode: .commonModes)
        danmakuView.play()
    }
    
    @objc
    func pause() {
        timer?.invalidate()
        timer = nil
        danmakuView.pause()
    }
    
    @objc
    func stop() {
        timer?.invalidate()
        timer = nil
        danmakuView.stop()
    }
    
    func randomIntNumber(lower: Int = 0,upper: Int = Int(UInt32.max)) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower)))
    }
    
    lazy var danmakuView: DanmakuView = {
        let view = DanmakuView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH
        , height: 300))
        view.backgroundColor = .blue
        return view
    }()
    
    lazy var playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("play", for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.addTarget(self, action: #selector(play), for: .touchUpInside)
        return view
    }()
    
    lazy var pauseButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("pause", for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.addTarget(self, action: #selector(pause), for: .touchUpInside)
        return view
    }()
    
    lazy var stopButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("stop", for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.addTarget(self, action: #selector(stop), for: .touchUpInside)
        return view
    }()

}

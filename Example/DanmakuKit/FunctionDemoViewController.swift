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
    
    private var displayTime: Double = 8
    
    private var danmakus: [DanmakuTextCellModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(danmakuView)
        view.addSubview(playButton)
        view.addSubview(pauseButton)
        view.addSubview(stopButton)
        view.addSubview(changeSpeedLabel)
        view.addSubview(changeSpeedSlder)
        
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
        
        changeSpeedLabel.sizeToFit()
        changeSpeedLabel.frame.origin.y = 600
        changeSpeedLabel.frame.origin.x = SCREEN_WIDTH / 2.0 - 40 - changeSpeedLabel.frame.width
        changeSpeedSlder.frame.origin.y = changeSpeedLabel.frame.minY
        changeSpeedSlder.frame.origin.x = changeSpeedLabel.frame.maxX + 15
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
        cellModel.displayTime = displayTime
        cellModel.text = contents[index]
        cellModel.id = String(arc4random())
        cellModel.calculateSize()
        if randomIntNumber(lower: 0, upper: 20) <= 5 {
            cellModel.type = .top
        } else if randomIntNumber(lower: 0, upper: 20) >= 15 {
            cellModel.type = .bottom
        }
        danmakuView.shoot(danmaku: cellModel)
        danmakus.append(cellModel)
    }
    
    @objc
    func play() {
        if timer == nil {
            timer = Timer(timeInterval:0.3, target: self, selector: #selector(sendDanmaku), userInfo: nil, repeats: true)
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
    
    @objc
    func changeSpeed(_ sender: UISlider) {
        danmakuView.update { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.displayTime = Double(sender.value)
            strongSelf.danmakus.forEach {
                $0.displayTime = displayTime
            }
        }
    }
    
    func randomIntNumber(lower: Int = 0,upper: Int = Int(UInt32.max)) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower)))
    }
    
    lazy var danmakuView: DanmakuView = {
        let view = DanmakuView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH
        , height: 300))
        view.backgroundColor = .blue
        view.delegate = self
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
    
    lazy var changeSpeedLabel: UILabel = {
        let view = UILabel()
        view.text = "change speed"
        view.textColor = .black
        return view
    }()
    
    lazy var changeSpeedSlder: UISlider = {
        let view = UISlider(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH / 2.0, height: 20))
        view.minimumValue = 5
        view.maximumValue = 10
        view.value = 8
        view.addTarget(self, action: #selector(changeSpeed(_:)), for: .touchUpInside)
        return view
    }()

}

extension FunctionDemoViewController: DanmakuViewDelegate {
    
    func danmakuView(_ danmakuView: DanmakuView, didEndDisplaying danmaku: DanmakuCell) {
        guard let model = danmaku.model as? DanmakuTextCellModel else { return }
        danmakus.removeAll { (cm) -> Bool in
            return cm.id == model.id
        }
    }
    
}

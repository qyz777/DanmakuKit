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
    
    private var danmakus: [AnyObject & DanmakuCellModel & TestDanmakuCellModel] = []
    
    private var interval: TimeInterval = 0.5

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(danmakuView)
        view.addSubview(playButton)
        view.addSubview(pauseButton)
        view.addSubview(stopButton)
        view.addSubview(changeSpeedLabel)
        view.addSubview(changeSpeedSlider)
        view.addSubview(changeHeightLabel)
        view.addSubview(changeHeightSlider)
        view.addSubview(changeAreaLabel)
        view.addSubview(changeAreaSlider)
        view.addSubview(overlapLabel)
        view.addSubview(overlapSwitch)
        view.addSubview(topLabel)
        view.addSubview(topSwitch)
        view.addSubview(floatingLabel)
        view.addSubview(floatingSwitch)
        view.addSubview(bottomLabel)
        view.addSubview(bottomSwitch)
        view.addSubview(syncButton)
        view.addSubview(syncSlider)
        view.addSubview(cleanButton)
        view.addSubview(playSpeedLabel)
        view.addSubview(playSpeedSlider)
        
        danmakuView.frame.origin.y = 100
        playButton.sizeToFit()
        pauseButton.sizeToFit()
        stopButton.sizeToFit()
        
        playButton.center.x = SCREEN_WIDTH / 2.0
        playButton.frame.origin.y = 350
        
        pauseButton.center.x = SCREEN_WIDTH / 2.0
        pauseButton.frame.origin.y = 380
        
        stopButton.center.x = SCREEN_WIDTH / 2.0
        stopButton.frame.origin.y = 410
        
        changeSpeedLabel.sizeToFit()
        changeSpeedLabel.frame.origin.y = 440
        changeSpeedLabel.frame.origin.x = SCREEN_WIDTH / 2.0 - 40 - changeSpeedLabel.frame.width
        changeSpeedSlider.frame.origin.y = changeSpeedLabel.frame.minY
        changeSpeedSlider.frame.origin.x = changeSpeedLabel.frame.maxX + 15
        
        changeHeightLabel.sizeToFit()
        changeHeightLabel.frame.origin.y = 470
        changeHeightLabel.frame.origin.x = SCREEN_WIDTH / 2.0 - 40 - changeHeightLabel.frame.width
        changeHeightSlider.frame.origin.y = changeHeightLabel.frame.minY
        changeHeightSlider.frame.origin.x = changeHeightLabel.frame.maxX + 15
        
        changeAreaLabel.sizeToFit()
        changeAreaLabel.frame.origin.y = 500
        changeAreaLabel.frame.origin.x = SCREEN_WIDTH / 2.0 - 40 - changeAreaLabel.frame.width
        changeAreaSlider.frame.origin.y = changeAreaLabel.frame.minY
        changeAreaSlider.frame.origin.x = changeAreaLabel.frame.maxX + 15
        
        overlapLabel.sizeToFit()
        overlapLabel.frame.origin.y = 530
        overlapLabel.frame.origin.x = SCREEN_WIDTH / 2.0 - 40 - overlapLabel.frame.width
        overlapSwitch.sizeToFit()
        overlapSwitch.center.y = overlapLabel.center.y
        overlapSwitch.frame.origin.x = overlapLabel.frame.maxX + 15
        
        topLabel.sizeToFit()
        topLabel.frame.origin.y = 570
        topLabel.frame.origin.x = SCREEN_WIDTH / 2.0 - 40 - topLabel.frame.width
        topSwitch.sizeToFit()
        topSwitch.center.y = topLabel.center.y
        topSwitch.frame.origin.x = topLabel.frame.maxX + 15
        
        floatingLabel.sizeToFit()
        floatingLabel.frame.origin.y = 610
        floatingLabel.frame.origin.x = SCREEN_WIDTH / 2.0 - 40 - floatingLabel.frame.width
        floatingSwitch.sizeToFit()
        floatingSwitch.center.y = floatingLabel.center.y
        floatingSwitch.frame.origin.x = floatingLabel.frame.maxX + 15
        
        bottomLabel.sizeToFit()
        bottomLabel.frame.origin.y = 650
        bottomLabel.frame.origin.x = SCREEN_WIDTH / 2.0 - 40 - bottomLabel.frame.width
        bottomSwitch.sizeToFit()
        bottomSwitch.center.y = bottomLabel.center.y
        bottomSwitch.frame.origin.x = bottomLabel.frame.maxX + 15
        
        syncButton.sizeToFit()
        syncButton.frame.origin.y = 680
        syncButton.frame.origin.x = SCREEN_WIDTH / 2.0 - 40 - syncButton.frame.width
        syncSlider.frame.origin.y = syncButton.frame.minY
        syncSlider.frame.origin.x = syncButton.frame.maxX + 15
        
        cleanButton.sizeToFit()
        cleanButton.center.x = SCREEN_WIDTH / 2.0
        cleanButton.frame.origin.y = 710
        
        playSpeedLabel.sizeToFit()
        playSpeedLabel.frame.origin.y = 740
        playSpeedLabel.frame.origin.x = SCREEN_WIDTH / 2.0 - 40 - playSpeedLabel.frame.width
        playSpeedSlider.frame.origin.y = playSpeedLabel.frame.minY
        playSpeedSlider.frame.origin.x = playSpeedLabel.frame.maxX + 15
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stop()
    }
    
    private let contents: [String] = [
        "我是一条长长的弹幕",
        "我是测试",
        "测试一条弹幕",
        "😈😈😈😈😈😈😈😈😈😈"
    ]
    
    @objc
    func sendDanmaku() {
        let randomNumber = randomIntNumber(lower: 0, upper: 100)
        if randomNumber < 70 {
            sendCommonDanmaku()
        } else {
            sendGifDanmaku()
        }
    }
    
    @objc
    func play() {
        if timer == nil {
            timer = Timer(timeInterval: interval, target: self, selector: #selector(sendDanmaku), userInfo: nil, repeats: true)
        }
        guard let timer = timer else { return }
        RunLoop.main.add(timer, forMode: .common)
        danmakuView.play()
        sendDanmaku()
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
            for i in 0..<strongSelf.danmakus.count {
                strongSelf.danmakus[i].displayTime = displayTime
            }
        }
    }
    
    @objc
    func changeHeight(_ sender: UISlider) {
        danmakuView.update { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.danmakuView.trackHeight = CGFloat(sender.value)
        }
    }
    
    @objc
    func changeArea(_ sender: UISlider) {
        danmakuView.update { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.danmakuView.displayArea = CGFloat(sender.value)
        }
    }
    
    @objc
    func overlapChange(_ sender: UISwitch) {
        if sender.isOn {
            interval = 0.05
        } else {
            interval = 0.5
        }
        danmakuView.isOverlap = sender.isOn
    }
    
    @objc
    func topChange(_ sender: UISwitch) {
        danmakuView.enableTopDanmaku = sender.isOn
    }
    
    @objc
    func floatingChange(_ sender: UISwitch) {
        danmakuView.enableFloatingDanmaku = sender.isOn
    }
    
    @objc
    func bottomChange(_ sender: UISwitch) {
        danmakuView.enableBottomDanmaku = sender.isOn
    }
    
    @objc
    func sync(_ sender: UIButton) {
        let cellModel = DanmakuTextCellModel(json: nil)
        cellModel.displayTime = displayTime
        cellModel.text = "Sync Danmaku"
        cellModel.identifier = String(arc4random())
        cellModel.calculateSize()
        if randomIntNumber(lower: 0, upper: 20) <= 5 {
            cellModel.type = .top
        } else if randomIntNumber(lower: 0, upper: 20) >= 15 {
            cellModel.type = .bottom
        }
        danmakus.append(cellModel)
        danmakuView.sync(danmaku: cellModel, at: syncSlider.value)
    }
    
    @objc
    func clean(_ sender: UIButton) {
        danmakuView.clean()
    }
    
    @objc
    func playSpeedChange(_ sender: UISlider) {
        danmakuView.playingSpeed = sender.value
    }
    
    func randomIntNumber(lower: Int = 0,upper: Int = Int(UInt32.max)) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower)))
    }
    
    func sendCommonDanmaku() {
        let index = randomIntNumber(lower: 0, upper: contents.count)
        let cellModel = DanmakuTextCellModel(json: nil)
        cellModel.displayTime = displayTime
        cellModel.text = contents[index]
        cellModel.identifier = String(arc4random())
        cellModel.calculateSize()
        if randomIntNumber(lower: 0, upper: 20) <= 5 {
            cellModel.type = .top
        } else if randomIntNumber(lower: 0, upper: 20) >= 15 {
            cellModel.type = .bottom
        }
        danmakuView.shoot(danmaku: cellModel)
        danmakus.append(cellModel)
    }
    
    func sendGifDanmaku() {
        let cellModel = DanmakuTestGifCellModel()
        cellModel.displayTime = displayTime
        cellModel.identifier = String(arc4random())
        cellModel.size = CGSize(width: 20, height: 20)
        danmakuView.shoot(danmaku: cellModel)
        danmakus.append(cellModel)
    }
    
    lazy var danmakuView: DanmakuView = {
        let view = DanmakuView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH
        , height: 250))
        view.backgroundColor = .black
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
    
    lazy var changeSpeedSlider: UISlider = {
        let view = UISlider(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH / 2.0, height: 20))
        view.minimumValue = 5
        view.maximumValue = 10
        view.value = 8
        view.addTarget(self, action: #selector(changeSpeed(_:)), for: .touchUpInside)
        return view
    }()
    
    lazy var changeHeightLabel: UILabel = {
        let view = UILabel()
        view.text = "change track height"
        view.textColor = .black
        return view
    }()
    
    lazy var changeHeightSlider: UISlider = {
        let view = UISlider(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH / 2.0, height: 20))
        view.minimumValue = 15
        view.maximumValue = 30
        view.value = 20
        view.addTarget(self, action: #selector(changeHeight(_:)), for: .touchUpInside)
        return view
    }()
    
    lazy var changeAreaLabel: UILabel = {
        let view = UILabel()
        view.text = "change display area"
        view.textColor = .black
        return view
    }()
    
    lazy var changeAreaSlider: UISlider = {
        let view = UISlider(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH / 2.0, height: 20))
        view.minimumValue = 0
        view.maximumValue = 1
        view.value = 1
        view.addTarget(self, action: #selector(changeArea(_:)), for: .touchUpInside)
        return view
    }()
    
    lazy var overlapLabel: UILabel = {
        let view = UILabel()
        view.text = "overlap"
        view.textColor = .black
        return view
    }()
    
    lazy var overlapSwitch: UISwitch = {
        let view = UISwitch(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        view.isOn = false
        view.addTarget(self, action: #selector(overlapChange(_:)), for: .valueChanged)
        return view
    }()
    
    lazy var topLabel: UILabel = {
        let view = UILabel()
        view.text = "enable top"
        view.textColor = .black
        return view
    }()
    
    lazy var topSwitch: UISwitch = {
        let view = UISwitch(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        view.isOn = true
        view.addTarget(self, action: #selector(topChange(_:)), for: .valueChanged)
        return view
    }()
    
    lazy var floatingLabel: UILabel = {
        let view = UILabel()
        view.text = "enable floating"
        view.textColor = .black
        return view
    }()
    
    lazy var floatingSwitch: UISwitch = {
        let view = UISwitch(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        view.isOn = true
        view.addTarget(self, action: #selector(floatingChange(_:)), for: .valueChanged)
        return view
    }()
    
    lazy var bottomLabel: UILabel = {
        let view = UILabel()
        view.text = "enable bottom"
        view.textColor = .black
        return view
    }()
    
    lazy var bottomSwitch: UISwitch = {
        let view = UISwitch(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        view.isOn = true
        view.addTarget(self, action: #selector(bottomChange(_:)), for: .valueChanged)
        return view
    }()
    
    lazy var syncButton: UIButton = {
        let view = UIButton()
        view.setTitle("sync danmaku", for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.addTarget(self, action: #selector(sync(_:)), for: .touchUpInside)
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    lazy var syncSlider: UISlider = {
        let view = UISlider(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH / 2.0, height: 20))
        view.minimumValue = 0
        view.maximumValue = 1
        view.value = 1
        return view
    }()
    
    lazy var cleanButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("clean", for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.addTarget(self, action: #selector(clean(_:)), for: .touchUpInside)
        return view
    }()
    
    lazy var playSpeedLabel: UILabel = {
        let view = UILabel()
        view.text = "play speed"
        view.textColor = .black
        return view
    }()
    
    lazy var playSpeedSlider: UISlider = {
        let view = UISlider(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH / 2.0, height: 20))
        view.minimumValue = 0.5
        view.maximumValue = 3
        view.value = 1
        view.addTarget(self, action: #selector(playSpeedChange(_:)), for: .touchUpInside)
        return view
    }()

}

extension FunctionDemoViewController: DanmakuViewDelegate {
    
    func danmakuView(_ danmakuView: DanmakuView, didEndDisplaying danmaku: DanmakuCell) {
        guard let model = danmaku.model else { return }
        danmakus.removeAll { (cm) -> Bool in
            return cm.isEqual(to: model)
        }
    }
    
    func danmakuView(_ danmakuView: DanmakuView, didTapped danmaku: DanmakuCell) {
        guard var cellModel = danmaku.model as? (DanmakuCellModel & TestDanmakuCellModel) else { return }
        if let cm = danmaku.model as? DanmakuTextCellModel {
            print("tap %@ at tarck %d", cm.text, cm.track ?? 0)
        }
        if cellModel.isPause {
            danmakuView.play(cellModel)
            cellModel.isPause = false
        } else {
            danmakuView.pause(cellModel)
            cellModel.isPause = true
        }
    }
    
}

//
//  DanmakuComponent.swift
//  DanmakuKit_Example
//
//  Created by QiYiZhong on 2024/1/30.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import DanmakuKit

class DanmakuComponent: NSObject, PlayerComponent {
    
    let context: ComponentContext
    
    var playerView: VideoPlayerView {
        return context.get(service: PlayerService.self).playerView
    }
    
    var controlView: UIView {
        return context.get(service: PlayerControlService.self).controlView
    }
    
    private var danmakuArray: [AnyObject & DanmakuCellModel & TestDanmakuCellModel] = []
    
    private var timerObserver: Any?
    
    private var statusObserver: Any?
    
    required init(_ context: ComponentContext) {
        self.context = context
        super.init()
    }
    
    func viewDidLoad() {
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
        
        timerObserver = playerView.$currentTime.sink { [weak self] in
            guard let self = self else { return }
            var array: [AnyObject & DanmakuCellModel & TestDanmakuCellModel] = []
            for cm in self.danmakuArray {
                if cm.offsetTime <= $0 {
                    array.append(cm)
                } else {
                    break
                }
            }
            self.danmakuArray.removeFirst(array.count)
            array.forEach {
                $0.calculateSize()
                self.danmakuView.shoot(danmaku: $0)
            }
        }
        
        statusObserver = playerView.$status.sink { [weak self] in
            guard let self = self else { return }
            switch $0 {
            case .playing:
                self.danmakuView.play()
            case .pause, .complete:
                self.danmakuView.pause()
            case .stopped, .failed:
                self.danmakuView.stop()
            default: break
            }
        }
        
        controlView.addSubview(danmakuView)
    }
    
    func layoutSubviews() {
        danmakuView.frame = controlView.bounds
        danmakuView.recalculateTracks()
    }
    
    private lazy var danmakuService: DanmakuService = {
        let s = DanmakuService()
        return s
    }()
    
    private lazy var danmakuView: DanmakuView = {
        let danmakuView = DanmakuView(frame: controlView.bounds)
        return danmakuView
    }()
    
}

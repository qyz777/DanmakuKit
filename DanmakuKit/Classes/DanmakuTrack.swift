//
//  DanmakuTrack.swift
//  DanmakuKit
//
//  Created by Q YiZhong on 2020/8/17.
//

import UIKit

protocol DanmakuTrack {
    
    init(view: UIView)
    
    func shoot(danmaku: DanmakuCell)
    
    func canShoot(danmaku: DanmakuCellModel) -> Bool
    
    func play()
    
    func pause()
    
    func stop()
    
    var positionY: CGFloat { get set }
    
}

let FLOATING_ANIMATION_KEY = "FLOATING_ANIMATION_KEY"
let DANMAKU_CELL_KEY = "DANMAKU_CELL_KEY"

class DanmakuFloatingTrack: NSObject, DanmakuTrack, CAAnimationDelegate {
    
    var positionY: CGFloat = 0
    
    private var cells: [DanmakuCell] = []
    
    private weak var view: UIView?
    
    var stopClosure: ((_ cell: DanmakuCell) -> Void)?
    
    required init(view: UIView) {
        self.view = view
    }
    
    func shoot(danmaku: DanmakuCell) {
        danmaku.layer.position = CGPoint(x: view!.bounds.width + danmaku.bounds.width / 2.0, y: positionY)
        addAnimation(to: danmaku)
        cells.append(danmaku)
    }
    
    func canShoot(danmaku: DanmakuCellModel) -> Bool {
        //初中数学的追击问题
        guard let cell = cells.last else { return true }
        guard let cellModel = cell.model else { return true }
        
        //1. 获取前一个cell剩余的运动时间
        let prevCellTime = cell.realFrame.maxX / view!.bounds.width * CGFloat(cellModel.displayTime)
        //2. 计算出路程差
        let distance = view!.bounds.width - cell.realFrame.maxX
        let preV = Float(view!.bounds.width / CGFloat(cellModel.displayTime))
        let nextV = Float(view!.bounds.width / CGFloat(danmaku.displayTime))
        //3. 计算出速度差
        let velocity = CGFloat(fabsf(preV - nextV))
        //4. 计算出追击时间
        let time = distance / velocity
        
        if time < prevCellTime {
            //弹幕会追击到前一个
            return false
        }
        
        return true
    }
    
    func play() {
        cells.forEach {
            addAnimation(to: $0)
        }
    }
    
    func pause() {
        cells.forEach {
            $0.center = CGPoint(x: $0.realFrame.midX, y: $0.realFrame.midY)
            $0.layer.removeAllAnimations()
        }
    }
    
    func stop() {
        cells.forEach {
            $0.removeFromSuperview()
            $0.layer.removeAllAnimations()
        }
        cells.removeAll()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let danmaku = anim.value(forKey: DANMAKU_CELL_KEY) as? DanmakuCell else { return }
        danmaku.center = CGPoint(x: danmaku.realFrame.midX, y: danmaku.realFrame.midY)
        danmaku.layer.removeAllAnimations()
        if danmaku.center.x <= -danmaku.frame.width {
            var findCell: DanmakuCell?
            cells.removeAll { (cell) -> Bool in
                let flag = cell == danmaku
                if flag {
                    findCell = cell
                }
                return flag
            }
            if let cell = findCell {
                stopClosure?(cell)
            }
        }
    }
    
    private func addAnimation(to danmaku: DanmakuCell) {
        guard let cellModel = danmaku.model else { return }
        let rate = danmaku.realFrame.midX / (view!.bounds.width + danmaku.frame.width)
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.beginTime = CACurrentMediaTime()
        animation.duration = cellModel.displayTime * Double(rate)
        animation.delegate = self
        animation.fromValue = NSNumber(value: Float(danmaku.layer.position.x))
        animation.toValue = NSNumber(value: Float(-danmaku.bounds.width / 2.0))
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.setValue(danmaku, forKey: DANMAKU_CELL_KEY)
        danmaku.layer.add(animation, forKey: FLOATING_ANIMATION_KEY)
    }
    
}

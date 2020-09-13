//
//  DanmakuTrack.swift
//  DanmakuKit
//
//  Created by Q YiZhong on 2020/8/17.
//

import UIKit

let MAX_FLOAT_X = CGFloat.infinity / 2.0

//MARK: DanmakuTrack

protocol DanmakuTrack {
    
    var positionY: CGFloat { get set }
    
    var stopClosure: ((_ cell: DanmakuCell) -> Void)? { get set }
    
    init(view: UIView)
    
    func shoot(danmaku: DanmakuCell)
    
    func canShoot(danmaku: DanmakuCellModel) -> Bool
    
    func play()
    
    func pause()
    
    func stop()
    
}

let FLOATING_ANIMATION_KEY = "FLOATING_ANIMATION_KEY"
let TOP_ANIMATION_KEY = "TOP_ANIMATION_KEY"
let DANMAKU_CELL_KEY = "DANMAKU_CELL_KEY"

//MARK: DanmakuFloatingTrack

class DanmakuFloatingTrack: NSObject, DanmakuTrack, CAAnimationDelegate {
    
    var positionY: CGFloat = 0
    
    var stopClosure: ((_ cell: DanmakuCell) -> Void)?
    
    private var cells: [DanmakuCell] = []
    
    private weak var view: UIView?
    
    required init(view: UIView) {
        self.view = view
    }
    
    func shoot(danmaku: DanmakuCell) {
        danmaku.layer.position = CGPoint(x: view!.bounds.width + danmaku.bounds.width / 2.0, y: positionY)
        prepare(danmaku: danmaku)
        addAnimation(to: danmaku)
        cells.append(danmaku)
    }
    
    func canShoot(danmaku: DanmakuCellModel) -> Bool {
        //初中数学的追击问题
        guard let cell = cells.last else { return true }
        guard let cellModel = cell.model else { return true }
        
        //1. 获取前一个cell剩余的运动时间
        let preWidth = view!.bounds.width + cell.frame.width
        let nextWidth = view!.bounds.width + danmaku.size.width
        let preRight = max(cell.realFrame.maxX, 0)
        let preCellTime = min(preRight / preWidth * CGFloat(cellModel.displayTime), CGFloat(cellModel.displayTime))
        //2. 计算出路程差，减10防止刚好追上
        let distance = view!.bounds.width - preRight - 10
        guard distance >= 0 else {
            //路程小于0说明当前轨道有一条弹幕刚发送
            return false
        }
        let preV = preWidth / CGFloat(cellModel.displayTime)
        let nextV = nextWidth / CGFloat(danmaku.displayTime)
        //3. 计算出速度差
        if nextV - preV <= 0 {
            //速度差小于等于0说明永远也追不上
            return true
        }
        //4. 计算出追击时间
        let time = (distance / (nextV - preV))
        
        if time < preCellTime {
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
        danmaku.animationTime += CFAbsoluteTimeGetCurrent() - danmaku.animationBeginTime
        if flag {
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
                danmaku.layer.removeAllAnimations()
                danmaku.frame.origin.x = MAX_FLOAT_X
            }
        }
    }
    
    private func addAnimation(to danmaku: DanmakuCell) {
        guard let cellModel = danmaku.model else { return }
        danmaku.animationBeginTime = CFAbsoluteTimeGetCurrent()
        let rate = danmaku.frame.midX / (view!.bounds.width + danmaku.frame.width)
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

//MARK: DanmakuTopTrack

class DanmakuVerticalTrack: NSObject, DanmakuTrack, CAAnimationDelegate {
    
    var positionY: CGFloat = 0
    
    var stopClosure: ((_ cell: DanmakuCell) -> Void)?
    
    var cell: DanmakuCell?
    
    private weak var view: UIView?
    
    required init(view: UIView) {
        self.view = view
    }
    
    func shoot(danmaku: DanmakuCell) {
        cell = danmaku
        danmaku.layer.position = CGPoint(x: view!.bounds.width / 2.0, y: positionY)
        prepare(danmaku: danmaku)
        addAnimation(to: danmaku)
    }
    
    func canShoot(danmaku: DanmakuCellModel) -> Bool {
        return cell == nil
    }
    
    func play() {
        guard let cell = cell else { return }
        addAnimation(to: cell)
    }
    
    func pause() {
        guard let cell = cell else { return }
        cell.layer.removeAllAnimations()
    }
    
    func stop() {
        guard let cell = cell else { return }
        cell.removeFromSuperview()
        cell.layer.removeAllAnimations()
    }
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let danmaku = anim.value(forKey: DANMAKU_CELL_KEY) as? DanmakuCell else { return }
        danmaku.animationTime += CFAbsoluteTimeGetCurrent() - danmaku.animationBeginTime
        if flag {
            stopClosure?(danmaku)
            danmaku.layer.removeAllAnimations()
            danmaku.frame.origin.x = MAX_FLOAT_X
            cell = nil
        }
    }
    
    private func addAnimation(to danmaku: DanmakuCell) {
        guard let cellModel = danmaku.model else { return }
        danmaku.animationBeginTime = CFAbsoluteTimeGetCurrent()
        let rate = cellModel.displayTime == 0 ? 0 : (1 - danmaku.animationTime / cellModel.displayTime)
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.beginTime = CACurrentMediaTime() + cellModel.displayTime * rate
        animation.duration = 0
        animation.delegate = self
        animation.fromValue = 1
        animation.toValue = 0
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.setValue(danmaku, forKey: DANMAKU_CELL_KEY)
        danmaku.layer.add(animation, forKey: TOP_ANIMATION_KEY)
    }
    
}

func prepare(danmaku: DanmakuCell) {
    danmaku.animationTime = 0
    danmaku.animationBeginTime = 0
    danmaku.layer.opacity = 1
}

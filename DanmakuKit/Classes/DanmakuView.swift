//
//  DanmakuView.swift
//  DanmakuKit
//
//  Created by Q YiZhong on 2020/8/16.
//

import UIKit

public protocol DanmakuViewDelegate: class {
    
    func danmakuView(_ danmakuView: DanmakuView, dequeueReusable cell: DanmakuCell)
    
    func danmakuView(_ danmakuView: DanmakuView, noSpaceShoot danmaku: DanmakuCellModel)
    
    func danmakuView(_ danmakuView: DanmakuView, willDisplay danmaku: DanmakuCell)
    
    func danmakuView(_ danmakuView: DanmakuView, didEndDisplaying danmaku: DanmakuCell)
    
}

public extension DanmakuViewDelegate {
    
    func danmakuView(_ danmakuView: DanmakuView, dequeueReusable cell: DanmakuCell) {}
    
    func danmakuView(_ danmakuView: DanmakuView, noSpaceShoot danmaku: DanmakuCellModel) {}
    
    func danmakuView(_ danmakuView: DanmakuView, willDisplay danmaku: DanmakuCell) {}
    
    func danmakuView(_ danmakuView: DanmakuView, didEndDisplaying danmaku: DanmakuCell) {}
    
}

public enum DanmakuStatus {
    case play
    case pause
    case stop
}

public class DanmakuView: UIView {
    
    public weak var delegate: DanmakuViewDelegate?
    
    public var enableCellReusable = true
    
    public var trackHeight: CGFloat = 20
    
    public var paddingTop: CGFloat = 0
    
    public var paddingBottom: CGFloat = 0
    
    public private(set) var status: DanmakuStatus = .stop
    
    private var danmakuPool: [String: [DanmakuCell]] = [:]
    
    private var floatingTracks: [DanmakuTrack] = []

    override public init(frame: CGRect) {
        super.init(frame: frame)
        recaculateTrack()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        recaculateTrack()
    }

}

public extension DanmakuView {
    
    func shoot(danmaku: DanmakuCellModel) {
        guard status == .play else { return }
        var findCell: DanmakuCell?
        if enableCellReusable {
            var cells = danmakuPool[NSStringFromClass(danmaku.cellClass)]
            if cells == nil {
                danmakuPool[NSStringFromClass(danmaku.cellClass)] = []
            }
            findCell = (cells?.count ?? 0) > 0 ? cells?.removeFirst() : nil
        }
        
        if findCell == nil {
            let className = NSClassFromString(NSStringFromClass(danmaku.cellClass)) as! DanmakuCell.Type
            findCell = className.init(frame: CGRect(x: bounds.width, y: 0, width: danmaku.size.width, height: danmaku.size.height))
            findCell?.model = danmaku
        } else {
            delegate?.danmakuView(self, dequeueReusable: findCell!)
        }
        
        guard let cell = findCell else { return }
        guard let track = floatingTracks.first(where: { (t) -> Bool in
            return t.canShoot(danmaku: danmaku)
        }) else {
            delegate?.danmakuView(self, noSpaceShoot: danmaku)
            return
        }
        
        if cell.superview == nil {
            addSubview(cell)
        }
        
        delegate?.danmakuView(self, willDisplay: cell)
        cell.layer.setNeedsDisplay()
        track.shoot(danmaku: cell)
    }
    
    func canShoot(danmaku: DanmakuCellModel) -> Bool {
        guard status == .play else { return false }
        return (floatingTracks.first { (t) -> Bool in
            return t.canShoot(danmaku: danmaku)
        }) != nil
    }
    
    func recaculateTrack() {
        let perHeight = Float((bounds.height - paddingTop - paddingBottom) / trackHeight)
        let trackCount = Int(ceilf(Float(perHeight)))
        let diffFloatingTrackCount = trackCount - floatingTracks.count
        let startIndex = floatingTracks.count
        if diffFloatingTrackCount > 0 {
            for i in 0..<diffFloatingTrackCount {
                let track = DanmakuFloatingTrack(view: self)
                track.stopClosure = { [weak self] (cell) in
                    guard let strongSelf = self else { return }
                    guard let cs = cell.model?.cellClass else { return }
                    strongSelf.delegate?.danmakuView(strongSelf, didEndDisplaying: cell)
                    guard var array = strongSelf.danmakuPool[NSStringFromClass(cs)] else { return }
                    array.append(cell)
                }
                track.positionY = CGFloat(startIndex + i) * trackHeight + trackHeight / 2.0 + paddingTop
                floatingTracks.append(track)
            }
        } else if diffFloatingTrackCount < 0 {
            floatingTracks.removeLast(Int(abs(diffFloatingTrackCount)))
        }
    }
    
    
    func play() {
        guard status != .play else { return }
        floatingTracks.forEach {
            $0.play()
        }
        status = .play
    }
    
    func pause() {
        guard status != .pause else { return }
        floatingTracks.forEach {
            $0.pause()
        }
        status = .pause
    }
    
    func stop() {
        guard status != .stop else { return }
        floatingTracks.forEach {
            $0.stop()
        }
        status = .stop
    }
    
}

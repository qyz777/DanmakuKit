//
//  DanmakuView.swift
//  DanmakuKit
//
//  Created by Q YiZhong on 2020/8/16.
//

import UIKit

public protocol DanmakuViewDelegate: class {
    
    /// A  danmaku is about to be reused and cellModel is set for you before calling this method.
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku: danmaku
    func danmakuView(_ danmakuView: DanmakuView, dequeueReusable danmaku: DanmakuCell)
    
    ///  This method is called when the danmaku has no space to display
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku:  cellModel of danmaku
    func danmakuView(_ danmakuView: DanmakuView, noSpaceShoot danmaku: DanmakuCellModel)
    
    ///  This method is called when the danmaku is about to be displayed
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku:  danmaku
    func danmakuView(_ danmakuView: DanmakuView, willDisplay danmaku: DanmakuCell)
    
    /// This method is called when the danmaku is about to end
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku: danmaku
    func danmakuView(_ danmakuView: DanmakuView, didEndDisplaying danmaku: DanmakuCell)
    
    /// This method is called when danmaku is tapped.
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku: danmaku
    func danmakuView(_ danmakuView: DanmakuView, didTapped danmaku: DanmakuCell)
    
}

public extension DanmakuViewDelegate {
    
    func danmakuView(_ danmakuView: DanmakuView, dequeueReusable danmaku: DanmakuCell) {}
    
    func danmakuView(_ danmakuView: DanmakuView, noSpaceShoot danmaku: DanmakuCellModel) {}
    
    func danmakuView(_ danmakuView: DanmakuView, willDisplay danmaku: DanmakuCell) {}
    
    func danmakuView(_ danmakuView: DanmakuView, didEndDisplaying danmaku: DanmakuCell) {}
    
    func danmakuView(_ danmakuView: DanmakuView, didTapped danmaku: DanmakuCell) {}
    
}

public enum DanmakuStatus {
    case play
    case pause
    case stop
}

/// The number of queues to draw the danmaku. If you want to change it, you must do so before the danmakuView is first created.
public var DRAW_DANMAKU_QUEUE_COUNT = 16

public class DanmakuView: UIView {
    
    public weak var delegate: DanmakuViewDelegate?
    
    /// If this property is false, the danmaku will not be reused and danmakuView(_:dequeueReusable danmaku:) methods will not be called.
    public var enableCellReusable = true
    
    /// Each danmaku is in one track and the number of tracks in the view depends on the height of the track.
    public var trackHeight: CGFloat = 20 {
        didSet {
            guard oldValue != trackHeight else { return }
            recaculateTracks()
        }
    }
    
    /// Padding of top area, the actual offset of the top danmaku will refer to this property.
    public var paddingTop: CGFloat = 0 {
        didSet {
            guard oldValue != paddingTop else { return }
            recaculateTracks()
        }
    }
    
    /// Padding of bottom area, the actual offset of the bottom danmaku will refer to this property.
    public var paddingBottom: CGFloat = 0 {
        didSet {
            guard oldValue != paddingBottom else { return }
            recaculateTracks()
        }
    }
    
    /// State of play,  The danmaku can only be sent in play status.
    public private(set) var status: DanmakuStatus = .stop
    
    private var danmakuPool: [String: [DanmakuCell]] = [:]
    
    private var floatingTracks: [DanmakuTrack] = []
    
    private var topTracks: [DanmakuTrack] = []
    
    private var bottomTracks: [DanmakuTrack] = []

    public override init(frame: CGRect) {
        super.init(frame: frame)
        createPoolIfNeed()
        recaculateTracks()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for i in (0..<subviews.count).reversed() {
            let subView = subviews[i]
            if subView.layer.animationKeys() != nil, let presentationLayer = subView.layer.presentation() {
                let newPoint = layer.convert(point, to: presentationLayer)
                if presentationLayer.contains(newPoint) {
                    return subView
                }
            } else {
                let newPoint = convert(point, to: subView)
                if let findView = hitTest(newPoint, with: event) {
                    return findView
                }
            }
        }
        return self
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
            let tap = UITapGestureRecognizer(target: self, action: #selector(danmakuDidTap(_:)))
            findCell?.addGestureRecognizer(tap)
        } else {
            findCell?.model = danmaku
            delegate?.danmakuView(self, dequeueReusable: findCell!)
        }
        
        guard let cell = findCell else { return }
        
        let shootTrack: DanmakuTrack
        switch danmaku.type {
        case .floating:
            guard let track = floatingTracks.first(where: { (t) -> Bool in
                return t.canShoot(danmaku: danmaku)
            }) else {
                delegate?.danmakuView(self, noSpaceShoot: danmaku)
                return
            }
            shootTrack = track
        case .top:
            guard let track = topTracks.first(where: { (t) -> Bool in
                return t.canShoot(danmaku: danmaku)
            }) else {
                delegate?.danmakuView(self, noSpaceShoot: danmaku)
                return
            }
            shootTrack = track
            
        case .bottom:
            guard let track = bottomTracks.last(where: { (t) -> Bool in
                return t.canShoot(danmaku: danmaku)
            }) else {
                delegate?.danmakuView(self, noSpaceShoot: danmaku)
                return
            }
            shootTrack = track
        }
        
        if cell.superview == nil {
            addSubview(cell)
        }
        
        delegate?.danmakuView(self, willDisplay: cell)
        cell.layer.setNeedsDisplay()
        shootTrack.shoot(danmaku: cell)
    }
    
    func canShoot(danmaku: DanmakuCellModel) -> Bool {
        guard status == .play else { return false }
        switch danmaku.type {
        case .floating:
            return (floatingTracks.first { (t) -> Bool in
                return t.canShoot(danmaku: danmaku)
            }) != nil
        case .top:
            return (topTracks.first { (t) -> Bool in
                return t.canShoot(danmaku: danmaku)
            }) != nil
        case .bottom:
            return (bottomTracks.first { (t) -> Bool in
                return t.canShoot(danmaku: danmaku)
            }) != nil
        }
    }
    
    /// You can call this method when you need to change the size of the danmakuView.
    func recaculateTracks() {
        recaculateFloatingTracks()
        recaculateTopTracks()
        recaculateBottomTracks()
    }
    
    
    func play() {
        guard status != .play else { return }
        floatingTracks.forEach {
            $0.play()
        }
        topTracks.forEach {
            $0.play()
        }
        bottomTracks.forEach {
            $0.play()
        }
        status = .play
    }
    
    func pause() {
        guard status != .pause else { return }
        floatingTracks.forEach {
            $0.pause()
        }
        topTracks.forEach {
            $0.pause()
        }
        bottomTracks.forEach {
            $0.pause()
        }
        status = .pause
    }
    
    func stop() {
        guard status != .stop else { return }
        floatingTracks.forEach {
            $0.stop()
        }
        topTracks.forEach {
            $0.stop()
        }
        bottomTracks.forEach {
            $0.stop()
        }
        status = .stop
    }
    
    /// When you change some properties of the danmakuView or cellModel that might affect the danmaku, you must make changes in the closure of this method.
    /// E.g.This method will be used when you change the displayTime property in the cellModel.
    /// - Parameter closure: update closure
    func update(_ closure: () -> Void) {
        pause()
        closure()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.play()
        }
    }
    
}

private extension DanmakuView {
    
    func recaculateFloatingTracks() {
        let trackCount = Int(floorf(Float((bounds.height - paddingTop - paddingBottom) / trackHeight)))
        let offsetY = max(0, (bounds.height - CGFloat(trackCount) * trackHeight) / 2.0)
        let diffFloatingTrackCount = trackCount - floatingTracks.count
        if diffFloatingTrackCount > 0 {
            for _ in 0..<diffFloatingTrackCount {
                floatingTracks.append(DanmakuFloatingTrack(view: self))
            }
        } else if diffFloatingTrackCount < 0 {
            for i in max(0, floatingTracks.count + diffFloatingTrackCount)..<floatingTracks.count {
                floatingTracks[i].stop()
            }
            floatingTracks.removeLast(Int(abs(diffFloatingTrackCount)))
        }
        for i in 0..<floatingTracks.count {
            var track = floatingTracks[i]
            track.stopClosure = { [weak self] (cell) in
                guard let strongSelf = self else { return }
                guard let cs = cell.model?.cellClass else { return }
                strongSelf.delegate?.danmakuView(strongSelf, didEndDisplaying: cell)
                guard var array = strongSelf.danmakuPool[NSStringFromClass(cs)] else { return }
                array.append(cell)
            }
            track.index = UInt(i)
            track.positionY = CGFloat(i) * trackHeight + trackHeight / 2.0 + paddingTop + offsetY
        }
    }
    
    func recaculateTopTracks() {
        let trackCount = Int(floorf(Float((bounds.height - paddingTop - paddingBottom) / trackHeight)))
        let offsetY = max(0, (bounds.height - CGFloat(trackCount) * trackHeight) / 2.0)
        let diffFloatingTrackCount = trackCount - topTracks.count
        if diffFloatingTrackCount > 0 {
            for _ in 0..<diffFloatingTrackCount {
                topTracks.append(DanmakuVerticalTrack(view: self))
            }
        } else if diffFloatingTrackCount < 0 {
            for i in max(0, topTracks.count + diffFloatingTrackCount)..<topTracks.count {
                topTracks[i].stop()
            }
            topTracks.removeLast(Int(abs(diffFloatingTrackCount)))
        }
        for i in 0..<topTracks.count {
            var track = topTracks[i]
            track.stopClosure = { [weak self] (cell) in
                guard let strongSelf = self else { return }
                guard let cs = cell.model?.cellClass else { return }
                strongSelf.delegate?.danmakuView(strongSelf, didEndDisplaying: cell)
                guard var array = strongSelf.danmakuPool[NSStringFromClass(cs)] else { return }
                array.append(cell)
            }
            track.index = UInt(i)
            track.positionY = CGFloat(i) * trackHeight + trackHeight / 2.0 + paddingTop + offsetY
        }
    }
    
    func recaculateBottomTracks() {
        let trackCount = Int(floorf(Float((bounds.height - paddingTop - paddingBottom) / trackHeight)))
        let offsetY = max(0, (bounds.height - CGFloat(trackCount) * trackHeight) / 2.0)
        let diffFloatingTrackCount = trackCount - bottomTracks.count
        if diffFloatingTrackCount > 0 {
            for _ in 0..<diffFloatingTrackCount {
                bottomTracks.insert(DanmakuVerticalTrack(view: self), at: 0)
            }
        } else if diffFloatingTrackCount < 0 {
            for i in 0..<min(bottomTracks.count, abs(diffFloatingTrackCount)) {
                bottomTracks[i].stop()
            }
            bottomTracks.removeFirst(Int(abs(diffFloatingTrackCount)))
        }
        for i in 0..<bottomTracks.count {
            var track = bottomTracks[i]
            track.stopClosure = { [weak self] (cell) in
                guard let strongSelf = self else { return }
                guard let cs = cell.model?.cellClass else { return }
                strongSelf.delegate?.danmakuView(strongSelf, didEndDisplaying: cell)
                guard var array = strongSelf.danmakuPool[NSStringFromClass(cs)] else { return }
                array.append(cell)
            }
            track.index = UInt(i)
            track.positionY = CGFloat(i) * trackHeight + trackHeight / 2.0 + paddingTop + offsetY
        }
    }
    
    @objc
    func danmakuDidTap(_ tap: UITapGestureRecognizer) {
        guard let view = tap.view as? DanmakuCell else { return }
        delegate?.danmakuView(self, didTapped: view)
    }
    
    func createPoolIfNeed() {
        guard pool == nil else { return }
        pool = DanmakuQueuePool(name: "com.DanmakuKit.DanmakuAsynclayer", queueCount: DRAW_DANMAKU_QUEUE_COUNT, qos: .userInteractive)
    }
    
}

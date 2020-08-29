//
//  DanmakuView.swift
//  DanmakuKit
//
//  Created by Q YiZhong on 2020/8/16.
//

import UIKit

public protocol DanmakuViewDelegate: class {
    
    func danmakuView(_ danmakuView: DanmakuView, dequeueReusable cell: DanmakuCell)
    
}

extension DanmakuViewDelegate {
    
    func danmakuView(_ danmakuView: DanmakuView, dequeueReusable cell: DanmakuCell) {}
    
}

public class DanmakuView: UIView {
    
    public weak var delegate: DanmakuViewDelegate?
    
    public var enableCellReusable = true
    
    public var trackHeight: CGFloat = 20
    
    public var paddingTop: CGFloat = 0
    
    public var paddingBottom: CGFloat = 0
    
    private var danmakuPool: [String: [DanmakuCell]] = [:]
    
    private var floatingTracks: [DanmakuTrack] = []
    
    private var nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String

    override init(frame: CGRect) {
        super.init(frame: frame)
        recaculateTrack()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

public extension DanmakuView {
    
    func register(nameSpace: String) {
        self.nameSpace = nameSpace
    }
    
    func shoot(danmaku: DanmakuCellModel) {
        var findCell: DanmakuCell?
        if enableCellReusable {
            var cells = danmakuPool[NSStringFromClass(danmaku.cellClass)]
            findCell = cells?.removeFirst()
        }
        
        if findCell == nil {
            let className = NSClassFromString(danmaku.nameSpace ?? nameSpace + "." + NSStringFromClass(danmaku.cellClass)) as! DanmakuCell.Type
            findCell = className.init(frame: .zero)
        } else {
            delegate?.danmakuView(self, dequeueReusable: findCell!)
        }
        
        guard let cell = findCell else { return }
        guard let track = floatingTracks.first(where: { (t) -> Bool in
            return t.canShoot(danmaku: danmaku)
        }) else { return }
        
        track.shoot(danmaku: cell)
    }
    
    func canShoot(danmaku: DanmakuCellModel) -> Bool {
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
                track.positionY = CGFloat(startIndex + i) * trackHeight + trackHeight / 2.0 + paddingTop
                floatingTracks.append(track)
            }
        } else if diffFloatingTrackCount < 0 {
            floatingTracks.removeLast(Int(abs(diffFloatingTrackCount)))
        }
    }
    
}

//
//  DanmakuView.swift
//  DanmakuKit
//
//  Created by Q YiZhong on 2020/8/16.
//

// Use shared platform typealiases (PlatformView) from PlatformTypes.swift
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public protocol DanmakuViewDelegate: AnyObject {
    
    /// A  danmaku is about to be reused and cellModel is set for you before calling this method.
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku: danmaku
    func danmakuView(_ danmakuView: DanmakuView, dequeueReusable danmaku: DanmakuCell)
    
    ///  This method is called when the danmaku has no space to display.
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku:  cellModel of danmaku
    func danmakuView(_ danmakuView: DanmakuView, noSpaceShoot danmaku: DanmakuCellModel)
    
    ///  This method is called when the danmaku is about to be displayed.
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku:  danmaku
    func danmakuView(_ danmakuView: DanmakuView, willDisplay danmaku: DanmakuCell)
    
    /// This method is called when the danmaku is about to end.
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku: danmaku
    func danmakuView(_ danmakuView: DanmakuView, didEndDisplaying danmaku: DanmakuCell)
    
    /// This method is called when danmaku is tapped.
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku: danmaku
    func danmakuView(_ danmakuView: DanmakuView, didTapped danmaku: DanmakuCell)
    
    ///  This method is called when the danmaku has no space to sync display.
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku:  cellModel of danmaku
    func danmakuView(_ danmakuView: DanmakuView, noSpaceSync danmaku: DanmakuCellModel)
    
#if os(macOS)

    /// This method is called when the danmaku hovered in macOS
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku:  cell of danmaku
    func danmakuView(_ danmakuView: DanmakuView, didHovered danmaku: DanmakuCell)

    /// This method is called when the danmaku stop hovered in macOS
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku:  cell of danmaku
    func danmakuView(_ danmakuView: DanmakuView, stopHovered danmaku: DanmakuCell)

#endif

    /// This method is called when the danmaku is toggled by tap
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku:  cell of danmaku
    func danmakuView(_ danmakuView: DanmakuView, didToggled danmaku: DanmakuCell)

    /// This method is called when the danmaku stop toggled
    /// - Parameters:
    ///   - danmakuView: view of the danmaku
    ///   - danmaku:  cell of danmaku
    func danmakuView(_ danmakuView: DanmakuView, stopToggled danmaku: DanmakuCell)
}

public extension DanmakuViewDelegate {
    
    func danmakuView(_ danmakuView: DanmakuView, dequeueReusable danmaku: DanmakuCell) {}
    
    func danmakuView(_ danmakuView: DanmakuView, noSpaceShoot danmaku: DanmakuCellModel) {}
    
    func danmakuView(_ danmakuView: DanmakuView, willDisplay danmaku: DanmakuCell) {}
    
    func danmakuView(_ danmakuView: DanmakuView, didEndDisplaying danmaku: DanmakuCell) {}
    
    func danmakuView(_ danmakuView: DanmakuView, didTapped danmaku: DanmakuCell) {}
    
    func danmakuView(_ danmakuView: DanmakuView, noSpaceSync danmaku: DanmakuCellModel) {}
#if os(macOS)
    func danmakuView(_ danmakuView: DanmakuView, didHovered danmaku: DanmakuCell) {}
    
    func danmakuView(_ danmakuView: DanmakuView, stopHovered danmaku: DanmakuCell) {}
#endif
    func danmakuView(_ danmakuView: DanmakuView, didToggled danmaku: DanmakuCell) {}
    
    func danmakuView(_ danmakuView: DanmakuView, stopToggled danmaku: DanmakuCell) {}
    
}

public enum DanmakuStatus {
    case play
    case pause
    case stop
}

public class DanmakuView: PlatformView {
    
    public weak var delegate: DanmakuViewDelegate?
    
    /// If this property is false, the danmaku will not be reused and danmakuView(_:dequeueReusable danmaku:) methods will not be called.
    public var enableCellReusable = false
    
    /// Each danmaku is in one track and the number of tracks in the view depends on the height of the track.
    public var trackHeight: CGFloat = 20 {
        didSet {
            guard oldValue != trackHeight else { return }
            recalculateTracks()
        }
    }
    
    /// Padding of top area, the actual offset of the top danmaku will refer to this property.
    public var paddingTop: CGFloat = 0 {
        didSet {
            guard oldValue != paddingTop else { return }
            recalculateTracks()
        }
    }
    
    /// Padding of bottom area, the actual offset of the bottom danmaku will refer to this property.
    public var paddingBottom: CGFloat = 0 {
        didSet {
            guard oldValue != paddingBottom else { return }
            recalculateTracks()
        }
    }
    
    /// State of play,  The danmaku can only be sent in play status.
    public private(set) var status: DanmakuStatus = .stop
    
    /// The display area of the danmaku is set between 0 and 1. Setting this property will affect the number of danmaku tracks.
    public var displayArea: CGFloat = 1.0 {
        willSet {
            assert(0 <= newValue && newValue <= 1, "Danmaku display area must be between [0, 1].")
        }
        didSet {
            guard oldValue != displayArea else { return }
            recalculateTracks()
        }
    }
    
    /// If this property is true, the danmaku supports overlapping launches. Default is false.
    public var isOverlap: Bool = false {
        didSet {
            for i in 0..<floatingTracks.count {
                floatingTracks[i].isOverlap = isOverlap
            }
            for i in 0..<topTracks.count {
                topTracks[i].isOverlap = isOverlap
            }
            for i in 0..<bottomTracks.count {
                bottomTracks[i].isOverlap = isOverlap
            }
        }
    }
    
    /// All floating danmaku are removed immediately after set false, and it won't be launched again. Default is true.
    public var enableFloatingDanmaku: Bool = true {
        didSet {
            if !enableFloatingDanmaku {
                floatingTracks.forEach {
                    $0.stop()
                }
            }
        }
    }
    
    /// All top danmaku are removed immediately after set false, and it won't be launched again. Default is true.
    public var enableTopDanmaku: Bool = true {
        didSet {
            if !enableTopDanmaku {
                topTracks.forEach {
                    $0.stop()
                }
            }
        }
    }
    
    /// All bottom danmaku are removed immediately after set false, and it won't be launched again. Default is true.
    public var enableBottomDanmaku: Bool = true {
        didSet {
            if !enableBottomDanmaku {
                bottomTracks.forEach {
                    $0.stop()
                }
            }
        }
    }
    
    public var playingSpeed: Float = 1.0 {
        willSet {
            assert(newValue > 0, "Danmaku playing speed must be over 0.")
        }
        didSet {
            // Apply iOS behavior on all platforms: pause -> update -> short delay -> play
            // This ensures existing on-screen danmaku recompute durations with the new speed.
            update {
                for i in 0..<floatingTracks.count {
                    var track = floatingTracks[i]
                    track.playingSpeed = playingSpeed
                }
                for i in 0..<topTracks.count {
                    var track = topTracks[i]
                    track.playingSpeed = playingSpeed
                }
                for i in 0..<bottomTracks.count {
                    var track = bottomTracks[i]
                    track.playingSpeed = playingSpeed
                }
            }
        }
    }
    
    private var danmakuPool: [String: [DanmakuCell]] = [:]
    
    private var floatingTracks: [DanmakuTrack] = []
    
    private var topTracks: [DanmakuTrack] = []
    
    private var bottomTracks: [DanmakuTrack] = []
    
    private var toggledCell: DanmakuCell?

#if os(macOS)
    private var hoveredCell: DanmakuCell?
#endif
    
    private var viewHeight: CGFloat {
        return bounds.height * displayArea
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        recalculateTracks()
        // 统一用父级视图的GestureRegnizer管理子视图点击事件
#if os(macOS)
        let containerClick = NSClickGestureRecognizer(target: self, action: #selector(containerDidClick(_:)))
        containerClick.delaysPrimaryMouseButtonEvents = false
        self.addGestureRecognizer(containerClick)
#else
        let bgTap = UITapGestureRecognizer(target: self, action: #selector(danmakuDidTap(_:)))
        bgTap.delaysTouchesBegan = false
        bgTap.delaysTouchesEnded = false
        self.addGestureRecognizer(bgTap)
#endif
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
#if os(macOS)
    // Use a top-left origin like iOS so tracks are laid out from the top.
    public override var isFlipped: Bool { true }
    
    public override func layout() {
        super.layout()
        recalculateTracks()
    }
#else
    public override func layoutSubviews() {
        super.layoutSubviews()
        recalculateTracks()
    }
#endif
    
    deinit {
        stop()
    }
    
#if os(macOS)
    public override func hitTest(_ point: NSPoint) -> NSView? {
        guard !isHidden, alphaValue > 0 else { return nil }
        guard self.bounds.contains(point) else { return nil }
        for sub in subviews.reversed() {
            var local = self.convert(point, to: sub)
            if let presentation = sub.layer?.presentation() {
                local = self.layer?.convert(point, to: presentation) ?? local
            }
            if let found = sub.hitTest(local) { return found }
        }
        return self
    }
    
    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.acceptsMouseMovedEvents = true
        setupHoverTracking()
    }
    
    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        setupHoverTracking()
    }
    
    private func setupHoverTracking() {
        trackingAreas.forEach { removeTrackingArea($0) }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
    }
    
    public override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        let point = convert(event.locationInWindow, from: nil)
        if let cell = locateDanmakuCell(at: point) {
            switchCurrentHovered(cell)
        } else {
            stopCurrentHovered()
        }
    }
    
    public override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        stopCurrentHovered()
    }
    
    private func switchCurrentHovered(_ cell: DanmakuCell) {
        guard cell !== hoveredCell else { return }
        stopCurrentHovered()
        hoveredCell = cell
        delegate?.danmakuView(self, didHovered: cell)
    }
    
    private func stopCurrentHovered() {
        if let old = hoveredCell {
            delegate?.danmakuView(self, stopHovered: old)
        }
        hoveredCell = nil
    }
    
#else
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.point(inside: point, with: event) else { return nil }
        for i in (0..<subviews.count).reversed() {
            let subView = subviews[i]
            var newPoint: CGPoint
            if subView.layer.animationKeys() != nil, let presentationLayer = subView.layer.presentation() {
                newPoint = layer.convert(point, to: presentationLayer)
            } else {
                newPoint = convert(point, to: subView)
            }
            if let findView = subView.hitTest(newPoint, with: event) { return findView }
        }
        return self
    }
#endif
    
    private func switchCurrentToggled(_ cell: DanmakuCell) {
        guard cell !== toggledCell else { return }
        stopCurrentToggled()
        toggledCell = cell
        delegate?.danmakuView(self, didToggled: cell)
    }
    
    private func stopCurrentToggled() {
        if let old = toggledCell {
            delegate?.danmakuView(self, stopToggled: old)
        }
        toggledCell = nil
    }
    
}

public extension DanmakuView {
    
    func shoot(danmaku: DanmakuCellModel) {
        guard status == .play else { return }
        switch danmaku.type {
        case .floating:
            guard enableFloatingDanmaku else { return }
            guard !floatingTracks.isEmpty else { return }
        case .top:
            guard enableTopDanmaku else { return }
            guard !topTracks.isEmpty else { return }
        case .bottom:
            guard enableBottomDanmaku else { return }
            guard !bottomTracks.isEmpty else { return }
        }
        
        guard let cell = obtainCell(with: danmaku) else { return }
        
        let shootTrack: DanmakuTrack
        if isOverlap {
            shootTrack = findLeastNumberDanmakuTrack(for: danmaku)
        } else {
            guard let t = findSuitableTrack(for: danmaku) else {
                delegate?.danmakuView(self, noSpaceShoot: danmaku)
                if enableCellReusable {
                    appendCellToPool(cell)
                }
                return
            }
            shootTrack = t
        }
        
        if cell.superview == nil {
            addSubview(cell)
        }
        delegate?.danmakuView(self, willDisplay: cell)
        cell.redraw()
        shootTrack.shoot(danmaku: cell)
    }
    
    func canShoot(danmaku: DanmakuCellModel) -> Bool {
        guard status == .play else { return false }
        switch danmaku.type {
        case .floating:
            guard enableFloatingDanmaku else { return false }
            return (floatingTracks.first { (t) -> Bool in
                return t.canShoot(danmaku: danmaku)
            }) != nil
        case .top:
            guard enableTopDanmaku else { return false }
            return (topTracks.first { (t) -> Bool in
                return t.canShoot(danmaku: danmaku)
            }) != nil
        case .bottom:
            guard enableBottomDanmaku else { return false }
            return (bottomTracks.first { (t) -> Bool in
                return t.canShoot(danmaku: danmaku)
            }) != nil
        }
    }
    
    /// You can call this method when you need to change the size of the danmakuView.
    func recalculateTracks() {
        recalculateFloatingTracks()
        recalculateTopTracks()
        recalculateBottomTracks()
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
    
    @discardableResult
    func play(_ danmaku: DanmakuCellModel) -> Bool {
        var track = floatingTracks.first { (t) -> Bool in
            return t.play(danmaku)
        }
        if track == nil {
            track = topTracks.first(where: { (t) -> Bool in
                return t.play(danmaku)
            })
        }
        if track == nil {
            track = bottomTracks.first(where: { (t) -> Bool in
                return t.play(danmaku)
            })
        }
        return track != nil
    }
    
    @discardableResult
    func pause(_ danmaku: DanmakuCellModel) -> Bool {
        var track = floatingTracks.first { (t) -> Bool in
            return t.pause(danmaku)
        }
        if track == nil {
            track = topTracks.first(where: { (t) -> Bool in
                return t.pause(danmaku)
            })
        }
        if track == nil {
            track = bottomTracks.first(where: { (t) -> Bool in
                return t.pause(danmaku)
            })
        }
        return track != nil
    }
    
    /// Display a danmaku synchronously according to the progress. If the status is stop, it will not work.
    /// - Parameters:
    ///   - danmaku: danmakuCellModel
    ///   - progress: progress of danmaku display
    func sync(danmaku: DanmakuCellModel, at progress: Float) {
        guard status != .stop else { return }
        assert(progress <= 1.0, "Cannot sync danmaku at progress \(progress).")
        switch danmaku.type {
        case .floating:
            guard enableFloatingDanmaku else { return }
            guard !floatingTracks.isEmpty else { return }
        case .top:
            guard enableTopDanmaku else { return }
            guard !topTracks.isEmpty else { return }
        case .bottom:
            guard enableBottomDanmaku else { return }
            guard !bottomTracks.isEmpty else { return }
        }
        guard let cell = obtainCell(with: danmaku) else { return }
        
        let syncTrack: DanmakuTrack
        if isOverlap {
            syncTrack = findLeastNumberDanmakuTrack(for: danmaku)
        } else {
            guard let t = findSuitableSyncTrack(for: danmaku, at: progress) else {
                delegate?.danmakuView(self, noSpaceSync: danmaku)
                return
            }
            syncTrack = t
        }
        
        if cell.superview == nil {
            addSubview(cell)
        }
        delegate?.danmakuView(self, willDisplay: cell)
        cell.redraw()
        if status == .play {
            syncTrack.syncAndPlay(cell, at: progress)
        } else {
            syncTrack.sync(cell, at: progress)
        }
    }
    
    /// Clean all the currently displayed danmaku.
    func clean() {
        floatingTracks.forEach { $0.clean() }
        bottomTracks.forEach { $0.clean() }
        topTracks.forEach { $0.clean() }
#if os(macOS)
        hoveredCell = nil
#endif
        toggledCell = nil
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
    
    func recalculateFloatingTracks() {
        let trackCount = max(0, Int(floorf(Float((viewHeight - paddingTop - paddingBottom) / trackHeight))))
        let offsetY = max(0, (viewHeight - CGFloat(trackCount) * trackHeight) / 2.0)
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
                strongSelf.cellPlayingStop(cell)
            }
            track.index = UInt(i)
            track.playingSpeed = playingSpeed
            track.positionY = CGFloat(i) * trackHeight + trackHeight / 2.0 + paddingTop + offsetY
        }
    }
    
    func recalculateTopTracks() {
        let trackCount = max(0, Int(floorf(Float((viewHeight - paddingTop - paddingBottom) / trackHeight))))
        let offsetY = max(0, (viewHeight - CGFloat(trackCount) * trackHeight) / 2.0)
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
                strongSelf.cellPlayingStop(cell)
            }
            track.index = UInt(i)
            track.playingSpeed = playingSpeed
            track.positionY = CGFloat(i) * trackHeight + trackHeight / 2.0 + paddingTop + offsetY
        }
    }
    
    func recalculateBottomTracks() {
        let trackCount = max(0, Int(floorf(Float((viewHeight - paddingTop - paddingBottom) / trackHeight))))
        let offsetY = max(0, (viewHeight - CGFloat(trackCount) * trackHeight) / 2.0)
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
        for i in (0..<bottomTracks.count).reversed() {
            var track = bottomTracks[i]
            track.stopClosure = { [weak self] (cell) in
                guard let strongSelf = self else { return }
                strongSelf.cellPlayingStop(cell)
            }
            let index = bottomTracks.count - i - 1
            track.index = UInt(index)
            track.playingSpeed = playingSpeed
#if os(macOS)
            track.positionY = bounds.height - CGFloat(index) * trackHeight - trackHeight / 2.0 - paddingBottom - offsetY
#else
            track.positionY = bounds.height - CGFloat(index) * trackHeight - trackHeight / 2.0 - paddingTop - offsetY
#endif
        }
    }
    
    func findLeastNumberDanmakuTrack(for danmaku: DanmakuCellModel) -> DanmakuTrack {
        func findLeastNumberDanmaku(from tracks: [DanmakuTrack]) -> DanmakuTrack {
            //Find a track with the minimum danmaku number
            var index = 0
            var value = Int.max
            for i in 0..<tracks.count {
                let track = tracks[i]
                if track.danmakuCount < value {
                    value = track.danmakuCount
                    index = i
                }
            }
            return tracks[index]
        }
        switch danmaku.type {
        case .floating:
            return findLeastNumberDanmaku(from: floatingTracks)
        case .top:
            return findLeastNumberDanmaku(from: topTracks)
        case .bottom:
            return findLeastNumberDanmaku(from: bottomTracks)
        }
    }
    
    func findSuitableTrack(for danmaku: DanmakuCellModel) -> DanmakuTrack? {
        switch danmaku.type {
        case .floating:
            guard let track = floatingTracks.first(where: { (t) -> Bool in
                return t.canShoot(danmaku: danmaku)
            }) else {
                return nil
            }
            return track
        case .top:
            guard let track = topTracks.first(where: { (t) -> Bool in
                return t.canShoot(danmaku: danmaku)
            }) else {
                return nil
            }
            return track
        case .bottom:
            guard let track = bottomTracks.last(where: { (t) -> Bool in
                return t.canShoot(danmaku: danmaku)
            }) else {
                return nil
            }
            return track
        }
    }
    
    func findSuitableSyncTrack(for danmaku: DanmakuCellModel, at progress: Float) -> DanmakuTrack? {
        switch danmaku.type {
        case .floating:
            guard let track = floatingTracks.first(where: { (t) -> Bool in
                return t.canSync(danmaku, at: progress)
            }) else {
                return nil
            }
            return track
        case .top:
            guard let track = topTracks.first(where: { (t) -> Bool in
                return t.canSync(danmaku, at: progress)
            }) else {
                return nil
            }
            return track
        case .bottom:
            guard let track = bottomTracks.last(where: { (t) -> Bool in
                return t.canSync(danmaku, at: progress)
            }) else {
                return nil
            }
            return track
        }
    }
    
    func obtainCell(with danmaku: DanmakuCellModel) -> DanmakuCell? {
        var cell: DanmakuCell?
        if enableCellReusable {
            cell = cellFromPool(danmaku)
        }
        
        let frame = CGRect(x: bounds.width, y: 0, width: danmaku.size.width, height: danmaku.size.height)
        if cell == nil {
            guard let cls = NSClassFromString(NSStringFromClass(danmaku.cellClass)) as? DanmakuCell.Type else {
                assert(false, "Launched Danmaku must inherit from DanmakuCell!")
                return nil
            }
            cell = cls.init(frame: frame)
            cell?.model = danmaku
        } else {
            cell?.frame = frame
            cell?.model = danmaku
            delegate?.danmakuView(self, dequeueReusable: cell!)
        }
        return cell
    }
    
    func cellFromPool(_ danmaku: DanmakuCellModel) -> DanmakuCell? {
        var cells = danmakuPool[NSStringFromClass(danmaku.cellClass)]
        if cells == nil {
            cells = []
        }
        let cell = (cells?.count ?? 0) > 0 ? cells?.removeFirst() : nil
        danmakuPool[NSStringFromClass(danmaku.cellClass)] = cells
        return cell
    }
    
#if os(macOS)
    @objc
    private func containerDidClick(_ gesture: NSClickGestureRecognizer) {
        let p = gesture.location(in: self)
        if let cell = locateDanmakuCell(at: p) {
            delegate?.danmakuView(self, didTapped: cell)
            switchCurrentToggled(cell)
        } else {
            // Click on empty space → clear toggled cell
            stopCurrentToggled()
        }
    }
#endif
    
    private func locateDanmakuCell(at p: PlatformPoint) -> DanmakuCell? {
        for sub in subviews.reversed() {
            guard let cell = sub as? DanmakuCell else { continue }
            let rf = cell.realFrame
            let rect = CGRect(x: rf.midX - cell.bounds.width / 2.0,
                              y: rf.midY - cell.bounds.height / 2.0,
                              width: cell.bounds.width,
                              height: cell.bounds.height)
            if rect.contains(p) {
                return cell
            }
        }
        return nil
    }
    
    func appendCellToPool(_ cell: DanmakuCell) {
        guard let cs = cell.model?.cellClass else {
            cell.removeFromSuperview()
            return
        }
        var array = danmakuPool[NSStringFromClass(cs)]
        if array == nil {
            array = []
        }
        array?.append(cell)
        danmakuPool[NSStringFromClass(cs)] = array
    }
    
    func cellPlayingStop(_ cell: DanmakuCell) {
#if os(macOS)
        // Clean up hovered state if this cell was being hovered
        if cell.model?.identifier == hoveredCell?.model?.identifier {
            stopCurrentHovered()
        }
#endif
        // Clean up toggled state (cross-platform)
        if cell.model?.identifier == toggledCell?.model?.identifier {
            stopCurrentToggled()
        }
        // Match DanmuKitMac behavior: always remove from superview when a danmaku ends,
        // then optionally append to pool for reuse to avoid lingering views.
        delegate?.danmakuView(self, didEndDisplaying: cell)
        if enableCellReusable {
            self.appendCellToPool(cell)
        } else {
            cell.removeFromSuperview()
        }
    }
    
#if canImport(UIKit)
    @objc
    func danmakuDidTap(_ tap: UITapGestureRecognizer) {
        let p = tap.location(in: self)
        if let cell = locateDanmakuCell(at: p) {
            delegate?.danmakuView(self, didTapped: cell)
            switchCurrentToggled(cell)
        } else {
            stopCurrentToggled()
        }
    }
#endif
    
}

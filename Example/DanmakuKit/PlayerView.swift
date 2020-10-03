//
//  PlayerView.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2020/10/1.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation
import KVOController

public enum PlayerViewStatus {
    case playing
    case pause
    case stop
    case error
    case unknown
}

public protocol PlayerViewDelegate: class {
    
    func player(_ player: PlayerView, playAt time: Double)
    
    func player(_ player: PlayerView, didLoadVideoWith duration: Double)
    
    func player(_ player: PlayerView, loadVideoFailWith error: String)
    
    func player(_ player: PlayerView, statusDidChange status: PlayerViewStatus)
    
    func playerDidPlayToEndTime(_ player: PlayerView)
    
}

public extension PlayerViewDelegate {
    
    func player(_ player: PlayerView, playAt time: Double) {}
    
    func player(_ player: PlayerView, didLoadVideoWith duration: Double) {}
    
    func player(_ player: PlayerView, loadVideoFailWith error: String) {}
    
    func player(_ player: PlayerView, statusDidChange status: PlayerViewStatus) {}
    
    func playerDidPlayToEndTime(_ player: PlayerView) {}
    
}

public class PlayerView: UIView {
    
    public weak var delegate: PlayerViewDelegate?
    
    public private(set) var status: PlayerViewStatus = .stop
    
    public private(set) var playbackTime: TimeInterval = 0
    
    public var animationLayer: CALayer?
    
    private var playerLayer: AVPlayerLayer?
    
    private var timeObserver: Any?
    
    private var currentItem: AVPlayerItem?

    public init() {
        super.init(frame: .zero)
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
        animationLayer?.frame = bounds
    }
    
    public override var debugDescription: String {
        if currentItem != nil && currentItem!.error != nil {
            return currentItem!.error!.localizedDescription
        }
        return ""
    }
    
    @objc
    func playerItemDidPlayToEndTime() {
        status = .pause
        delegate?.player(self, statusDidChange: status)
        delegate?.playerDidPlayToEndTime(self)
    }
    
    private func updatePlayerItem(_ item: AVPlayerItem) {
        currentItem = item
        //变速时为了时player支持声音变速需要设置audioTimePitchAlgorithm
        currentItem?.audioTimePitchAlgorithm = .varispeed
        player.replaceCurrentItem(with: currentItem)
        kvoControllerNonRetaining.observe(currentItem!, keyPath: "status", options: [.initial, .new]) { [weak self] (_, _, change) in
            let status = AVPlayerItem.Status(rawValue: (change["new"] as! NSNumber).intValue)!
            if let strongSelf = self {
                //转发播放器状态出去
                if status == .readyToPlay {
                    //转发视频时间出去
                    let duration = strongSelf.currentItem!.asset.duration.seconds
                    strongSelf.delegate?.player(strongSelf, didLoadVideoWith: duration)
                } else if status == .failed || status == .unknown {
                    strongSelf.delegate?.player(strongSelf, loadVideoFailWith: strongSelf.currentItem!.error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    private func updatePlayerLayer() {
        playerLayer?.removeFromSuperlayer()
        playerLayer = AVPlayerLayer(player: player)
        layer.insertSublayer(playerLayer!, at: 0)
    }
    
    private lazy var player: AVPlayer = {
        return AVPlayer()
    }()

}

public extension PlayerView {
    
    func play() {
        guard currentItem != nil && timeObserver != nil else {
            return
        }
        guard status != .playing else {
            return
        }
        player.play()
        status = .playing
        delegate?.player(self, statusDidChange: status)
    }
    
    func stop() {
        guard status != .stop else {
            return
        }
        player.pause()
        if timeObserver != nil {
            player.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
        status = .stop
        player.cancelPendingPrerolls()
        delegate?.player(self, statusDidChange: status)
    }
    
    func pause() {
        guard status != .pause else {
            return
        }
        player.pause()
        status = .pause
        delegate?.player(self, statusDidChange: status)
    }
    
    func seek(to time: Double) {
        guard currentItem != nil else {
            return
        }
        let time = CMTime(seconds: time, preferredTimescale: CMTimeScale(600))
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func setup(url: URL) {
        let asset = AVURLAsset(url: url)
        setup(asset: asset)
    }
    
    func setup(asset: AVAsset) {
        let item = AVPlayerItem(asset: asset)
        updatePlayerItem(item)
        updatePlayerLayer()
        if timeObserver == nil {
            let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(600))
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
                if let strongSelf = self {
                    strongSelf.animationLayer?.timeOffset = time.seconds
                    strongSelf.playbackTime = time.seconds
                    //seek的时候也会调这个，判断一下状态不要回调出去
                    guard strongSelf.status == .playing else {
                        return
                    }
                    strongSelf.delegate?.player(strongSelf, playAt: time.seconds)
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
}

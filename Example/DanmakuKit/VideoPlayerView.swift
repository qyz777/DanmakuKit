//
//  VideoPlayerView.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2023/2/18.
//

import UIKit
import AVKit
import MediaPlayer

public enum VideoPlayerStatus {
    case unknown
    case readyToPlay
    case playing
    case pause
    case stopped
    case complete
    case failed
}

public class VideoPlayerView: UIView {
    
    public var playerItem: AVPlayerItem? {
        return player.currentItem
    }
    
    @Published var status: VideoPlayerStatus = .unknown
    
    @Published var currentTime: Double = .zero
    
    @Published var loadTimeRanges: [CMTimeRange] = []
    
    @Published var duration: Double = 0
    
    @Published var isBufferEmpty = false
    
    @Published var isLikelyToKeepUp = false
    
    public var error: Error? {
        return playerItem?.error
    }
    
    public var title: String?
    
    public var isSeeking = false
    
    public var isLoop = false
    
    public var videoRect: CGRect {
        return playerLayer.videoRect
    }
    
    public var speedRate: Float = 1.0 {
        didSet {
            if status == .playing {
                player.rate = speedRate
            }
        }
    }
    
    public var videoGravity: AVLayerVideoGravity = .resizeAspect {
        didSet {
            playerLayer.videoGravity = videoGravity
        }
    }
    
    public var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    private let player: AVPlayer = AVPlayer()
    
    private var videoOutput: AVPlayerItemVideoOutput?
    
    private var timeObserver: Any?
    
    private var observers: [Any] = []
    
    private var shouldPlay = false
    
    private var readyToPlay = false
    
    private var previewWaitFlag = true
    
    public override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    private func setup(_ item: AVPlayerItem) {
        readyToPlay = false
        shouldPlay = false
        currentTime = 0
        
        videoOutput = AVPlayerItemVideoOutput()
        item.add(videoOutput!)
        player.replaceCurrentItem(with: item)
        
        installPlayer()
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerLayer.videoGravity = videoGravity

        setupObserver(item)
        removeRemoteCommand()
        addRemoteCommand()
    }
    
    private func setupObserver(_ item: AVPlayerItem) {
        if let t = timeObserver {
            player.removeTimeObserver(t)
        }
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] in
            guard !(self?.isSeeking ?? false) && $0 != .zero else { return }
            self?.currentTime = $0.seconds
            self?.updateRemotePlayingInfo()
        }
        observers.append(player.publisher(for: \.rate, options: [.new]).sink { [weak self] in
            guard let self = self else { return }
            if $0 == 0 {
                if self.currentTime >= self.duration {
                    self.status = .complete
                    if self.isLoop {
                        self.play()
                    }
                } else {
                    self.status = .pause
                }
            }
        })
        observers.append(item.publisher(for: \.duration).sink { [weak self] in
            if ($0 == CMTime.indefinite) {
                self?.duration = 0
            } else {
                self?.duration = $0.seconds
            }
        })
        observers.append(item.publisher(for: \.status).sink { [weak self] in
            switch $0 {
            case .readyToPlay:
                self?.readyToPlay = true
                self?.status = .readyToPlay
                if self?.shouldPlay ?? false {
                    self?.play()
                }
            case .failed:
                self?.status = .failed
                if let error = self?.playerItem?.error?.localizedDescription {
                    logDebug("播放器发生错误: \(error)")
                }
            default:
                self?.status = .unknown
            }
        })
        observers.append(item.publisher(for: \.loadedTimeRanges).sink { [weak self] in
            self?.loadTimeRanges = $0.map({
                return $0.timeRangeValue
            })
        })
        observers.append(item.publisher(for: \.isPlaybackBufferEmpty).sink { [weak self] in
            self?.isBufferEmpty = $0
        })
        observers.append(item.publisher(for: \.isPlaybackLikelyToKeepUp).sink { [weak self] in
            self?.isLikelyToKeepUp = $0
        })
    }
    
    private func updateRemotePlayingInfo() {
        var info: [String: Any] = [:]
        info[MPMediaItemPropertyTitle] = title ?? ""
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPMediaItemPropertyPlaybackDuration] = duration
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func addRemoteCommand() {
        let pauseCommand = MPRemoteCommandCenter.shared().pauseCommand
        pauseCommand.isEnabled = true
        pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        let playCommand = MPRemoteCommandCenter.shared().playCommand
        playCommand.isEnabled = true
        playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        
        let seekCommand = MPRemoteCommandCenter.shared().changePlaybackPositionCommand
        seekCommand.isEnabled = true
        seekCommand.addTarget { [weak self] in
            guard let event = $0 as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seek(event.positionTime)
            return .success
        }
    }
    
    private func removeRemoteCommand() {
        MPRemoteCommandCenter.shared().pauseCommand.removeTarget(self)
        MPRemoteCommandCenter.shared().playCommand.removeTarget(self)
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.removeTarget(self)
    }
    
}

public extension VideoPlayerView {
    
    func installPlayer() {
        playerLayer.player = player
    }
    
    func uninstallPlayer() {
        playerLayer.player = nil
    }
    
    func update(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let item = AVPlayerItem(url: url)
        update(item)
    }
    
    func update(_ url: URL) {
        let item = AVPlayerItem(url: url)
        update(item)
    }
    
    func update(_ item: AVPlayerItem) {
        setup(item)
    }
    
    func play() {
        guard status != .playing else { return }
        if readyToPlay {
            if status == .complete {
                seek(.zero)
            }
            player.play()
            player.rate = speedRate
            status = .playing
        } else {
            shouldPlay = true
            if status == .complete {
                seek(.zero)
            }
        }
    }
    
    func pause() {
        guard status != .pause else { return }
        player.pause()
        status = .pause
    }
    
    func stop() {
        guard status != .stopped else { return }
        player.pause()
        player.replaceCurrentItem(with: nil)
        if let t = timeObserver {
            player.removeTimeObserver(t)
        }
        observers.removeAll()
        status = .stopped
        removeRemoteCommand()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    func seek(_ time: Double) {
        seek(time) {_ in }
    }
    
    func seek(_ time: Double, with completion: @escaping (Bool) -> Void) {
        isSeeking = true
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        logDebug("player seek to \(cmTime.seconds).")
        player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] in
            completion($0)
            self?.isSeeking = false
        }
    }
    
    func generateCurrentImage() -> UIImage? {
        guard let output = videoOutput else { return nil }
        guard let buffer = output.copyPixelBuffer(forItemTime: player.currentTime(), itemTimeForDisplay: nil) else { return nil }
        let ciImage = CIImage(cvImageBuffer: buffer)
        let context = CIContext(options: nil)
        guard let videoImage = context .createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))) else { return nil }
        return UIImage(cgImage: videoImage)
    }
    
}

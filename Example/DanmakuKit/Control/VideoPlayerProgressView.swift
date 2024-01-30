//
//  VideoPlayerProgressView.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2023/2/25.
//

import UIKit
import CoreMedia

class VideoPlayerProgressView: UIView {
    
    var duration: Double = 0 {
        didSet {
            totalTimeLabel.text = duration.calculateTimeString()
            if (duration > 0) {
                pan.isEnabled = true
                tap.isEnabled = true
            }
            if duration >= 3600 {
                overOneHour = true
                currentTimeLabel.text = currentTime.calculateTimeString(overOneHour: overOneHour)
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    var currentTime: Double = 0 {
        didSet {
            guard !isSeeking else { return }
            currentTimeLabel.text = currentTime.calculateTimeString(overOneHour: overOneHour)
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var progress: Double {
        guard duration > 0 && currentTime > 0 else {
            return 0
        }
        return currentTime / duration
    }
    
    var loadTimeRange: CMTimeRange = .zero {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var seekBegin: (() -> Void)?
    
    var seekEnd: (() -> Void)?
    
    var seekingClosure: ((_ duration: Double) -> Void)?
    
    var seekCompletion: ((_ time: Double, _ completion: @escaping (() -> Void)) -> Void)?
    
    var isSeeking = false
    
    var loadProgress: Double = 0
    
    var beginTrackX: CGFloat = 0
    
    var loadTimeView: [UIView] = []
    
    var overOneHour = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(currentTimeLabel)
        addSubview(totalTimeLabel)
        addSubview(progressTrackView)
        addSubview(loadProgressView)
        addSubview(progressView)
        addSubview(trackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        currentTimeLabel.sizeToFit()
        currentTimeLabel.width = overOneHour ? 54 : 36
        currentTimeLabel.left = 8
        currentTimeLabel.center.y = height / 2.0
        
        totalTimeLabel.sizeToFit()
        totalTimeLabel.width = overOneHour ? 54 : 36
        totalTimeLabel.right = width - 8
        totalTimeLabel.center.y = height / 2.0
        
        let progressWidth = width - 8 * 2 - currentTimeLabel.width - totalTimeLabel.width - 8 * 2
        progressTrackView.frame = CGRect(x: 0, y: 0, width: progressWidth, height: 2)
        progressTrackView.center.y = height / 2.0
        progressTrackView.left = currentTimeLabel.right + 8
        
        updateProgressIfNeeded()
    }
    
    func clear() {
        duration = 0
        currentTime = 0
        loadTimeRange = .zero
        loadProgressView.width = 0
    }
    
    func panTrack(_ pan: UIPanGestureRecognizer) {
        didPanTrack(pan)
    }
    
    func updateProgress() {
        let width = progressTrackView.width * CGFloat(progress)
        updateTrack(width)
        
        guard duration > 0 else { return }
        let loadWidth = CGFloat(loadTimeRange.duration.seconds / duration) * progressTrackView.width
        let left = CGFloat(loadTimeRange.start.seconds / duration) * progressTrackView.width
        loadProgressView.frame = CGRect(x: progressTrackView.left + left, y: progressTrackView.top, width: loadWidth, height: 2)
    }
    
    private func updateProgressIfNeeded() {
        guard !isSeeking else { return }
        updateProgress()
    }
    
    private func updateTrack(_ width: CGFloat) {
        progressView.frame = CGRect(origin: progressTrackView.frame.origin, size: CGSize(width: width, height: 2))
        trackView.center = CGPoint(x: progressTrackView.frame.minX + width, y: progressTrackView.center.y)
        bringSubviewToFront(trackView)
    }
    
    @objc private func didPanTrack(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            isSeeking = true
            beginTrackX = trackView.center.x
            seekBegin?()
        case .changed:
            let point = pan.translation(in: self)
            var x: CGFloat
            if pan == self.pan {
                x = beginTrackX + point.x
            } else {
                //拖动系数，影响seek手感
                let trackRate: CGFloat = 0.5
                x = beginTrackX + point.x * trackRate
            }
            x = CGFloat.maximum(progressTrackView.frame.minX, x)
            x = CGFloat.minimum(progressTrackView.frame.maxX, x)
            let width = x - progressTrackView.frame.minX
            updateTrack(width)
            let progress = (trackView.center.x - progressTrackView.frame.minX) / progressTrackView.width
            let time = duration * Double(progress)
            currentTimeLabel.text = time.calculateTimeString(overOneHour: overOneHour)
            seekingClosure?(time)
            setNeedsLayout()
            layoutIfNeeded()
        case .ended:
            let progress = (trackView.center.x - progressTrackView.frame.minX) / progressTrackView.width
            let time = duration * Double(progress)
            currentTime = time
            currentTimeLabel.text = time.calculateTimeString(overOneHour: overOneHour)
            setNeedsLayout()
            layoutIfNeeded()
            seekCompletion?(time, { [weak self] in
                self?.isSeeking = false
            })
            seekEnd?()
        default:
            return
        }
    }
    
    @objc private func didTapTrack(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: progressTrackView)
        var x = CGFloat.maximum(0, point.x)
        x = CGFloat.minimum(x, progressTrackView.width)
        updateTrack(x)
        let progress = point.x / progressTrackView.width
        let time = duration * Double(progress)
        currentTimeLabel.text = time.calculateTimeString(overOneHour: overOneHour)
        isSeeking = true
        setNeedsLayout()
        layoutIfNeeded()
        seekCompletion?(time, { [weak self] in
            self?.isSeeking = false
        })
    }
    
    lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "00:00"
        label.textAlignment = .center
        return label
    }()
    
    lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "00:00"
        label.textAlignment = .center
        return label
    }()
    
    lazy var progressTrackView: ExpandTouchView = {
        let view = ExpandTouchView()
        view.layer.cornerRadius = 1
        view.alpha = 0.2
        view.backgroundColor = .white
        view.addGestureRecognizer(tap)
        view.hitTestEdgeInsets = UIEdgeInsets(top: -15, left: 0, bottom: -15, right: 0)
        return view
    }()
    
    lazy var progressView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.backgroundColor = .white
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var loadProgressView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.alpha = 0.5
        view.backgroundColor = .white
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var trackView: ExpandTouchView = {
        let view = ExpandTouchView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        view.layer.cornerRadius = 3
        view.backgroundColor = .white
        view.hitTestEdgeInsets = UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15)
        view.addGestureRecognizer(pan)
        return view
    }()
    
    lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPanTrack(_:)))
        pan.isEnabled = false
        return pan
    }()
    
    lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapTrack(_:)))
        tap.isEnabled = false
        return tap
    }()
    
}

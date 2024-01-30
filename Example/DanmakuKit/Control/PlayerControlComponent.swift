//
//  PlayerControlComponent.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2023/3/25.
//

import UIKit
import MediaPlayer

protocol PlayerControlService {
    
    var controlView: UIView { get }
    
    var topContainerView: UIView { get }
    
    var bottomContainerView: UIView { get }
    
}

protocol PlayerControlEvent {
    
    func clickMoreButton()
    
    func layoutControlSubviews()
    
    func controlShowingChange(_ value: Bool)
    
}

extension PlayerControlEvent {
    
    func clickMoreButton() {}
    
    func layoutControlSubviews() {}
    
    func controlShowingChange(_ value: Bool) {}
    
}

enum PlayerPanType {
    case unknown
    case seek
    case audio
    case brightness
}

class PlayerControlComponent: NSObject, PlayerComponent {
    
    let context: ComponentContext
    
    var playerView: VideoPlayerView {
        return context.get(service: PlayerService.self).playerView
    }
    
    @Published var isControlShowing = true {
        didSet {
            context.send(event: PlayerControlEvent.self) {
                $0.controlShowingChange(isControlShowing)
            }
        }
    }
    
    var panType: PlayerPanType = .unknown
    
    var volume: Float {
        set {
            volumeSlider?.setValue(newValue, animated: false)
        }
        get {
            return volumeSlider?.value ?? AVAudioSession.sharedInstance().outputVolume
        }
    }
    
    var beginVolume: Float = 0
    
    var beginBrightness: CGFloat = 0
    
    var observers: [Any] = []
    
    required init(_ context: ComponentContext) {
        self.context = context
        super.init()
        context.register(service: PlayerControlService.self, for: self)
    }
    
    func viewDidLoad() {
        context.get(service: PlayerService.self).containerView.addSubview(controlView)
        controlView.addSubview(volumeView)
        controlView.addSubview(playButton)
        controlView.addSubview(topContainerView)
        controlView.addSubview(bottomContainerView)
        controlView.addSubview(audioProgressView)
        controlView.addSubview(brightnessProgressView)
        controlView.addSubview(seekHighlightLabel)
        topContainerView.addSubview(topContainerShadowView)
        topContainerView.addSubview(backButton)
        topContainerView.addSubview(moreButton)
        bottomContainerView.addSubview(bottomContainerShadowView)
        bottomContainerView.addSubview(bottomContainerBlurView)
        bottomContainerView.addSubview(smallPlayButton)
        bottomContainerView.addSubview(progressView)
        bottomContainerView.addSubview(fullScreenButton)
        
        setupObservers()
    }
    
    func layoutSubviews() {
        let safeArea = playerView.safeAreaInsets
        controlView.frame = context.get(service: PlayerService.self).containerView.bounds
        playButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        playButton.center = CGPoint(x: controlView.width / 2.0, y: controlView.height / 2.0)
        seekHighlightLabel.sizeToFit()
        seekHighlightLabel.center = CGPoint(x: controlView.width / 2.0, y: controlView.height / 2.0)
        topContainerView.frame = CGRect(x: 0, y: 0, width: controlView.width, height: 60)
        if UIApplication.isPortrait {
            topContainerView.top = controlView.safeAreaInsets.top
        } else {
            topContainerView.top = 0
        }
        topContainerShadowView.frame = topContainerView.bounds
        backButton.frame = CGRect(x: 12 + safeArea.left, y: 12, width: 32, height: 32)
        moreButton.frame = CGRect(x: topContainerView.width - 44 - safeArea.right, y: 12, width: 32, height: 32)
        audioProgressView.center.x = controlView.width / 2.0
        audioProgressView.top = topContainerView.bottom + 10
        brightnessProgressView.center.x = controlView.width / 2.0
        brightnessProgressView.top = topContainerView.bottom + 10
        
        if UIApplication.isLandscape {
            bottomContainerView.frame = CGRect(x: 0, y: controlView.height - 60, width: controlView.width, height: 60)
            bottomContainerView.layer.cornerRadius = 0
        } else {
            bottomContainerView.frame = CGRect(x: 12, y: controlView.height - 80 - controlView.safeAreaInsets.bottom, width: controlView.width - 24, height: 60)
            bottomContainerView.layer.cornerRadius = 8
            bottomContainerView.layer.masksToBounds = true
        }
        bottomContainerBlurView.frame = bottomContainerView.bounds
        bottomContainerShadowView.frame = bottomContainerView.bounds
        
        smallPlayButton.sizeToFit()
        smallPlayButton.left = 12 + safeArea.left
        smallPlayButton.center.y = bottomContainerView.height / 2.0
        fullScreenButton.sizeToFit()
        fullScreenButton.right = bottomContainerView.width - 12 - safeArea.right
        fullScreenButton.center.y = bottomContainerView.height / 2.0
        
        let progressWidth = bottomContainerView.width - smallPlayButton.width - 12 * 2 - fullScreenButton.width - safeArea.left - safeArea.right
        progressView.frame = CGRect(x: smallPlayButton.right, y: 0, width: progressWidth, height: bottomContainerView.height)
        progressView.updateProgress()
        
        bottomContainerBlurView.isHidden = UIApplication.isLandscape
        bottomContainerShadowView.isHidden = UIApplication.isPortrait
        topContainerShadowView.isHidden = UIApplication.isPortrait
        
        context.send(event: PlayerControlEvent.self) {
            $0.layoutControlSubviews()
        }
    }
    
    func viewDidAppear(_ animated: Bool) {
        observers.append(AVAudioSession.sharedInstance().publisher(for: \.outputVolume).dropFirst(1).sink { [weak self] in
            self?.updateAudioValue($0)
        })
        
        observers.append(UIScreen.main.publisher(for: \.brightness).dropFirst(1).sink { [weak self] in
            self?.updateBrightnessValue($0)
        })
    }
    
    func viewDidDisappear(_ animated: Bool) {
        observers.removeAll()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    // MARK: Action
    
    @objc func didTapPlay() {
        guard playerView.status != .complete else {
            return
        }
        if playerView.status == .playing {
            playerView.pause()
        } else {
            playerView.play()
        }
        changeControlShowingStatusDelay()
    }
    
    @objc func didTapView() {
        changeControlShowingStatus()
    }
    
    @objc func didDoubleTapView() {
        didTapPlay()
    }
    
    @objc func didClickFullScreenButton() {
        context.get(service: PlayerService.self).rotateScreen()
    }
    
    @objc func didClickBackButton() {
        if UIApplication.isLandscape {
            context.get(service: PlayerService.self).rotateScreen()
        } else {
            context.get(service: PlayerService.self).back()
        }
    }
    
    @objc func didClickMoreButton() {
        context.send(event: PlayerControlEvent.self) {
            $0.clickMoreButton()
        }
    }
    
    @objc func didPanControlView(_ pan: UIPanGestureRecognizer) {
        guard playerView.duration > 0 else {
            return
        }
        switch pan.state {
        case .began:
            isControlShowing = true
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenControlShowing), object: nil)
        case .ended:
            changeControlShowingStatusDelay()
        default:
            break
        }
        if (UIApplication.isPortrait) {
            progressView.panTrack(pan)
            return
        }
        switch pan.state {
        case .began:
            let point = pan.velocity(in: playerView)
            let location = pan.location(in: playerView)
            let isAudioArea = location.x >= playerView.width / 2.0
            if (abs(point.x) > abs(point.y)) {
                guard playerView.duration > 0 else {
                    return
                }
                panType = .seek
            } else {
                if isAudioArea {
                    panType = .audio
                } else {
                    panType = .brightness
                }
            }
            sendPlayerPanEvent(pan)
        case .changed:
            sendPlayerPanEvent(pan)
        case .ended:
            sendPlayerPanEvent(pan)
            panType = .unknown
        default:
            return
        }
    }
    
    // MARK: Private
    
    private func setupObservers() {
        observers.append(playerView.$status.sink { [weak self] in
            let image: UIImage?
            let smallImage: UIImage?
            let config = UIImage.SymbolConfiguration(pointSize: 60)
            let smallConfig = UIImage.SymbolConfiguration(pointSize: 16)
            if $0 == .playing {
                image = UIImage(systemName: "pause.fill", withConfiguration: config)
                smallImage = UIImage(systemName: "pause.fill", withConfiguration: smallConfig)
            } else if $0 == .failed {
                image = UIImage(systemName: "play.slash.fill", withConfiguration: config)
                smallImage = UIImage(systemName: "play.slash.fill", withConfiguration: smallConfig)
            } else {
                image = UIImage(systemName: "play.fill", withConfiguration: config)
                smallImage = UIImage(systemName: "play.fill", withConfiguration: smallConfig)
                if $0 == .readyToPlay {
                    self?.progressView.duration = self?.playerView.duration ?? 0
                    if (!(self?.progressView.isSeeking ?? false)) {
                        self?.progressView.currentTime = self?.playerView.currentTime ?? 0
                    }
                }
            }
            self?.playButton.setImage(image, for: .normal)
            self?.smallPlayButton.setImage(smallImage, for: .normal)
        })
        
        observers.append(playerView.$currentTime.sink { [weak self] in
            self?.progressView.currentTime = $0
        })
        
        observers.append(playerView.$loadTimeRanges.sink { [weak self] in
            self?.progressView.loadTimeRange = $0.first ?? .zero
        })
        
        observers.append(playerView.$duration.sink { [weak self] in
            self?.progressView.duration = $0
        })
        
        observers.append($isControlShowing.sink { [weak self] in
            guard let self = self else { return }
            self.playButton.isHidden = !$0
            self.topContainerView.isHidden = !$0
            self.bottomContainerView.isHidden = !$0
        })
    }
    
    private func changeControlShowingStatus() {
        isControlShowing = !isControlShowing
        changeControlShowingStatusDelay()
    }
    
    private func changeControlShowingStatusDelay () {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenControlShowing), object: nil)
        if (isControlShowing) {
            perform(#selector(hiddenControlShowing), with: nil, afterDelay: 3.0)
        }
    }
    
    @objc private func hiddenControlShowing() {
        isControlShowing = false
    }
    
    private func sendPlayerPanEvent(_ pan: UIPanGestureRecognizer) {
        switch panType {
        case .unknown:
            return
        case .seek:
            progressView.panTrack(pan)
        case .audio:
            handleAudioChange(with: pan)
        case .brightness:
            handleBrightnessChange(with: pan)
        }
    }
    
    private func handleAudioChange(with pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            beginVolume = volume
        case .changed:
            let point = pan.translation(in: playerView)
            let begin = audioProgressView.width * CGFloat(beginVolume)
            var current = begin - point.y
            current = CGFloat.minimum(current, audioProgressView.width)
            current = CGFloat.maximum(current, 0)
            volume = Float(current / audioProgressView.width)
        default:
            return
        }
    }
    
    private func handleBrightnessChange(with pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            beginBrightness = UIScreen.main.brightness
        case .changed:
            let point = pan.translation(in: playerView)
            let begin = brightnessProgressView.width * beginBrightness
            var current = begin - point.y
            current = CGFloat.minimum(current, brightnessProgressView.width)
            current = CGFloat.maximum(current, 0)
            UIScreen.main.brightness = current / brightnessProgressView.width
        default:
            return
        }
    }
    
    private func updateAudioValue(_ value: Float) {
        audioProgressView.isHidden = false
        brightnessProgressView.isHidden = true
        audioProgressView.progress = CGFloat(value)
        audioProgressView.hidden(afterDelay: 2.0)
    }
    
    private func updateBrightnessValue(_ value: CGFloat) {
        brightnessProgressView.isHidden = false
        audioProgressView.isHidden = true
        brightnessProgressView.progress = value
        brightnessProgressView.hidden(afterDelay: 2.0)
    }
    
    lazy var controlView: UIView = {
        let view = UIView()
        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(doubleTap)
        return view
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .custom)
        button.imageView?.tintColor = .white
        button.alpha = 0.8
        button.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        return button
    }()
    
    lazy var smallPlayButton: UIButton = {
        let button = ExpandTouchButton(type: .custom)
        button.imageView?.tintColor = .white
        button.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        return button
    }()
    
    lazy var bottomContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var bottomContainerBlurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blur)
        return view
    }()
    
    lazy var progressView: VideoPlayerProgressView = {
        let view = VideoPlayerProgressView(frame: .zero)
        view.seekCompletion = { [weak self] (time, completion) in
            guard let self = self else { return }
            self.playerView.seek(time, with: { _ in
                completion()
            })
        }
        view.seekBegin = { [weak self] in
            guard let self = self else { return }
            self.seekHighlightLabel.isHidden = false
            self.playButton.isHidden = true
        }
        view.seekingClosure = { [weak self] in
            guard let self = self else { return }
            let overOneHour = self.playerView.duration >= 3600
            let currentTime = $0.calculateTimeString(overOneHour: overOneHour)
            let durationTime = self.playerView.duration.calculateTimeString(overOneHour: overOneHour)
            self.seekHighlightLabel.text = "\(currentTime) / \(durationTime)"
            self.seekHighlightLabel.sizeToFit()
            self.seekHighlightLabel.center = CGPoint(x: self.controlView.width / 2.0, y: self.controlView.height / 2.0)
        }
        view.seekEnd = { [weak self] in
            guard let self = self else { return }
            self.seekHighlightLabel.isHidden = true
            self.playButton.isHidden = !self.isControlShowing
        }
        return view
    }()
    
    lazy var fullScreenButton: ExpandTouchButton = {
        let view = ExpandTouchButton(type: .custom)
        view.hitTestEdgeInsets = UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15)
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        view.setImage(UIImage(systemName: "viewfinder", withConfiguration: config), for: .normal)
        view.imageView?.tintColor = .white
        view.addTarget(self, action: #selector(didClickFullScreenButton), for: .touchUpInside)
        return view
    }()
    
    lazy var backButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 4
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        view.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        view.imageView?.tintColor = .white
        view.addTarget(self, action: #selector(didClickBackButton), for: .touchUpInside)
        return view
    }()
    
    lazy var moreButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 4
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        view.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        view.imageView?.tintColor = .white
        view.addTarget(self, action: #selector(didClickMoreButton), for: .touchUpInside)
        return view
    }()
    
    lazy var topContainerView: UIView = {
        return UIView()
    }()
    
    lazy var bottomContainerShadowView: GradientView = {
        let view = GradientView()
        view.isHidden = true
        view.gradientLayer.colors = [
            UIColor(hex: "#990f0f0f").cgColor,
            UIColor(hex: "#660f0f0f").cgColor,
            UIColor(hex: "#1A0f0f0f").cgColor,
            UIColor.clear.cgColor
        ]
        view.gradientLayer.locations = [
            NSNumber(0),
            NSNumber(0.2),
            NSNumber(0.6),
            NSNumber(1),
        ]
        view.gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        view.gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        return view
    }()
    
    lazy var topContainerShadowView: GradientView = {
        let view = GradientView()
        view.isHidden = true
        view.gradientLayer.colors = [
            UIColor(hex: "#990f0f0f").cgColor,
            UIColor(hex: "#660f0f0f").cgColor,
            UIColor(hex: "#1A0f0f0f").cgColor,
            UIColor.clear.cgColor
        ]
        view.gradientLayer.locations = [
            NSNumber(0),
            NSNumber(0.2),
            NSNumber(0.6),
            NSNumber(1),
        ]
        view.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        view.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        return view
    }()
    
    lazy var audioProgressView: PlayerCenterProgressView = {
        let view = PlayerCenterProgressView(frame: CGRect(x: 0, y: 0, width: 174, height: 20))
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        view.imageView.image = UIImage(systemName: "waveform", withConfiguration: config)
        view.imageView.tintColor = .white
        view.isHidden = true
        return view
    }()
    
    lazy var brightnessProgressView: PlayerCenterProgressView = {
        let view = PlayerCenterProgressView(frame: CGRect(x: 0, y: 0, width: 174, height: 20))
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        view.imageView.image = UIImage(systemName: "sun.max", withConfiguration: config)
        view.imageView.tintColor = .white
        view.isHidden = true
        return view
    }()
    
    lazy var volumeView: MPVolumeView = {
        let view = MPVolumeView(frame: CGRect(x: -100, y: -100, width: 40, height: 40))
        return view
    }()
    
    var volumeSlider: UISlider? {
        return volumeView.subviews.first {
            return NSStringFromClass(type(of: $0)) == "MPVolumeSlider"
        } as? UISlider
    }
    
    lazy var seekHighlightLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = .systemFont(ofSize: 30, weight: .semibold)
        view.isHidden = true
        view.alpha = 0.8
        return view
    }()
    
    lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tap.require(toFail: doubleTap)
        return tap
    }()
    
    lazy var doubleTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapView))
        tap.numberOfTapsRequired = 2
        return tap
    }()
    
    lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.addTarget(self, action: #selector(didPanControlView(_:)))
        return pan
    }()
    
}

extension PlayerControlComponent: PlayerControlService {
    
    
    
}

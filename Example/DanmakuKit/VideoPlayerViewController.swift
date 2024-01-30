//
//  VideoPlayerViewController.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2023/2/25.
//

import UIKit
import SwiftUI
import AVFAudio
import MediaPlayer

struct VideoModel {
    
    let url: String
    
    let title: String?
    
    var dataLength: Int64?
    
    var fileURL: URL? = nil
    
    var duration: TimeInterval = 0
    
    var startPlayTime: TimeInterval = 0
    
    var isDownload: Bool {
        return fileURL != nil
    }
    
}

typealias WatchTimeClosure = (_ time: TimeInterval) -> Void

struct VideoPlayer: View {
    
    @State var videoModel: VideoModel
    
    @State var watchTime: WatchTimeClosure
    
    var body: some View {
        ZStack {
            VideoPlayerVC(videoModel: videoModel) {
                watchTime($0)
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .background(Color.black)
    }
    
}

struct VideoPlayerVC: UIViewControllerRepresentable {
    
    @State var videoModel: VideoModel
    
    @State var watchTime: WatchTimeClosure
    
    @Environment(\.presentationMode) var mode
    
    typealias UIViewControllerType = VideoPlayerViewController
    
    
    func makeUIViewController(context: Context) -> VideoPlayerViewController {
        let vc = VideoPlayerViewController(videoModel)
        vc.popClosure = {
            mode.wrappedValue.dismiss()
        }
        vc.watchTimeClosure = {
            watchTime($0)
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: VideoPlayerViewController, context: Context) {
        
    }
    
}

protocol PlayerService: AnyObject {
    
    var containerView: UIView { get }
    
    var viewController: UIViewController { get }
    
    var playerView: VideoPlayerView { get }
    
    var speedRate: Float { get set }
    
    var videoGravity: AVLayerVideoGravity { get set }
    
    var isLoop: Bool { get set }
    
    var videoModel: VideoModel { get }
    
    var isBufferEmpty: Published<Bool>.Publisher { get }
    
    var isLikelyToKeepUp: Published<Bool>.Publisher { get }
    
    func rotateScreen()
    
    func back()
    
    func play()
    
    func pause()
    
    func layoutIfNeeded()
    
}

protocol PlayerViewControllerEvent {
    
}

class VideoPlayerViewController: UIViewController {
    
    var videoModel: VideoModel
    
    @Published var isControlShowing = true
    
    var popClosure: (() -> Void)?
    
    var watchTimeClosure: WatchTimeClosure?
    
    let componentCenter = PlayerComponentCenter()
    
    var context: ComponentContext {
        return componentCenter.context
    }
    
    // MARK: LifeCycle
    
    init(_ videoModel: VideoModel) {
        self.videoModel = videoModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        playerView.title = videoModel.title
        if let fileURL = videoModel.fileURL {
            playerView.update(fileURL)
        } else {
            playerView.update(videoModel.url)
        }
        
        if videoModel.startPlayTime > 0 {
            playerView.seek(videoModel.startPlayTime)
        }
        
        registerComponent()
        
        setupSubviews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        componentCenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.view.backgroundColor = .black
        AppOrientation.shared.orientation = .allButUpsideDown
        componentCenter.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.window?.overrideUserInterfaceStyle = .dark
        view.window?.rootViewController?.view.backgroundColor = .black
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            logDebug(error)
        }
        
        componentCenter.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.window?.overrideUserInterfaceStyle = .unspecified
        AppOrientation.shared.orientation = .portrait
        componentCenter.viewWillDisappear(animated)
        watchTimeClosure?(playerView.currentTime)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playerView.stop()
        NotificationCenter.default.removeObserver(self)
        componentCenter.viewDidDisappear(animated)
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            logDebug(error)
        }
    }
    
    override func viewWillLayoutSubviews() {
        playerView.frame = view.bounds
        componentCenter.layoutSubviews()
    }
    
    @objc func orientationDidChange() {
        componentCenter.orientationDidChange(UIDevice.current.orientation)
    }
    
    @objc func appDidEnterBackground() {
        componentCenter.appDidEnterBackground()
    }
    
    @objc func appDidBecomeActive() {
        componentCenter.appDidBecomeActive()
    }
    
    @objc func appWillEnterForeground() {
        componentCenter.appWillEnterForeground()
    }
    
    @objc func appWillResignActive() {
        componentCenter.appWillResignActive()
        watchTimeClosure?(playerView.currentTime)
    }
    
    private func setupSubviews() {
        view.insertSubview(playerView, at: 0)
    }
    
    private func registerComponent() {
        componentCenter.context.register(service: PlayerService.self, for: self)
        PlayerComponentRegister.register(center: componentCenter)
    }
    
    lazy var playerView: VideoPlayerView = {
        let view = VideoPlayerView()
        return view
    }()

}

extension VideoPlayerViewController: PlayerService {
    
    var isBufferEmpty: Published<Bool>.Publisher {
        return playerView.$isBufferEmpty
    }
    
    var isLikelyToKeepUp: Published<Bool>.Publisher {
        return playerView.$isLikelyToKeepUp
    }
    
    var containerView: UIView {
        return view
    }
    
    var viewController: UIViewController {
        return self
    }
    
    var speedRate: Float {
        set {
            playerView.speedRate = newValue
        }
        get {
            return playerView.speedRate
        }
    }
    
    var videoGravity: AVLayerVideoGravity {
        set {
            playerView.videoGravity = newValue
        }
        get {
            return playerView.videoGravity
        }
    }
    
    var isLoop: Bool {
        set {
            playerView.isLoop = newValue
        }
        get {
            return playerView.isLoop
        }
    }
    
    func rotateScreen() {
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            if UIApplication.isPortrait {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
            } else {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        } else {
            if UIApplication.isPortrait {
                UIDevice.current.setValue(UIDeviceOrientation.landscapeRight.rawValue, forKey: "orientation")
            } else {
                UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
        setNeedsStatusBarAppearanceUpdate()
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    func back() {
        popClosure?()
    }
    
    func play() {
        playerView.play()
    }
    
    func pause() {
        playerView.pause()
    }
    
    func layoutIfNeeded() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
}

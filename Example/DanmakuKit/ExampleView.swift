//
//  ExampleView.swift
//  DanmakuKit_Example
//
//  Created by QiYiZhong on 2024/1/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import DanmakuKit

struct ExampleView: View {
    
    @StateObject var viewModel = ExampleViewModel()
    
    var body: some View {
        ZStack {
            ExamplePlayerView(coordinator: viewModel.playerViewModel)
                .onStatusChanged { [weak viewModel] in
                    viewModel?.onStatusChanged($0)
                }
                .onCurrentTimeChanged { [weak viewModel] in
                    viewModel?.onCurrentTimeChanged($0)
                }
            DanmakuViewAdapter(coordinator: viewModel.danmakuViewModel)
        }
        .background(Color.black)
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
    
    class ExampleViewModel: ObservableObject {
        
        var danmakuArray: [AnyObject & DanmakuCellModel & TestDanmakuCellModel] = []
        
        var danmakuViewModel = DanmakuViewAdapter.Coordinator()
        
        var playerViewModel = ExamplePlayerView.Coordinator()
        
        func onAppear() {
            requestDanmaku()
            danmakuViewModel.danmakuView?.paddingTop = 20
            danmakuViewModel.danmakuView?.paddingBottom = 20
            playerViewModel.setupPlayer()
            playerViewModel.play()
        }
        
        func onDisappear() {
            playerViewModel.stop()
            playerViewModel.playerView = nil
            danmakuArray.removeAll()
        }
        
        func onStatusChanged(_ status: VideoPlayerStatus) {
            switch status {
            case .playing:
                danmakuViewModel.play()
            case .pause, .complete:
                danmakuViewModel.pause()
            case .stopped, .failed:
                danmakuViewModel.stop()
            default: break
            }
        }
        
        func onCurrentTimeChanged(_ time: TimeInterval) {
            var array: [AnyObject & DanmakuCellModel & TestDanmakuCellModel] = []
            for cm in danmakuArray {
                if cm.offsetTime <= time {
                    array.append(cm)
                } else {
                    break
                }
            }
            danmakuArray.removeFirst(array.count)
            array.forEach {
                $0.calculateSize()
                danmakuViewModel.shoot(danmaku: $0)
            }
        }
        
        func requestDanmaku() {
            Task {
                guard let json = await loadDanmakuJSON() else { return }
                danmakuArray = json["data"].arrayValue.map({ (json) -> AnyObject & DanmakuCellModel & TestDanmakuCellModel in
                    if json["danmaku_type"].int == 1 {
                        return DanmakuTestGifCellModel(json: json)
                    } else {
                        return DanmakuTextCellModel(json: json)
                    }
                })
            }
        }
        
        func loadDanmakuJSON() async -> JSON? {
            guard let url = Bundle.main.url(forResource: "danmaku", withExtension: "json") else { return nil }
            do {
                let data = try Data(contentsOf: url, options: .dataReadingMapped)
                let json = try JSON(data: data)
                return json
            } catch {
                return nil
            }
        }
        
    }
    
}

struct ExamplePlayerView: UIViewRepresentable {
    
    typealias UIViewType = VideoPlayerView
    
    @ObservedObject var coordinator: Coordinator
    
    private var onStatusChangedClosure: ((VideoPlayerStatus) -> Void)?
    
    private var onCurrentTimeChangedClosure: ((TimeInterval) -> Void)?
    
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }
    
    func makeUIView(context: Context) -> VideoPlayerView {
        return coordinator.makeView()
    }
    
    func updateUIView(_ uiView: VideoPlayerView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return coordinator
    }
    
    func onStatusChanged(_ closure: @escaping (VideoPlayerStatus) -> Void) -> Self {
        coordinator.onStatusChanged = closure
        return self
    }
    
    func onCurrentTimeChanged(_ closure: @escaping (TimeInterval) -> Void) -> Self {
        coordinator.onCurrentTimeChanged = closure
        return self
    }
    
    class Coordinator: ObservableObject {
        
        var playerView: VideoPlayerView?
        
        private var timeObserver: Any?
        
        private var statusObserver: Any?
        
        var onStatusChanged: ((VideoPlayerStatus) -> Void)?
        
        var onCurrentTimeChanged: ((TimeInterval) -> Void)?
        
        func makeView() -> VideoPlayerView {
            playerView = VideoPlayerView()
            return playerView!
        }
        
        func setupPlayer() {
            guard let url = Bundle.main.url(forResource: "demo", withExtension: "MOV") else { return }
            playerView?.update(url)
            timeObserver = playerView?.$currentTime.sink { [weak self] in
                guard let self = self else { return }
                self.onCurrentTimeChanged?($0)
            }
            statusObserver = playerView?.$status.sink { [weak self] in
                guard let self = self else { return }
                self.onStatusChanged?($0)
            }
        }
        
        func play() {
            playerView?.play()
        }
        
        func stop() {
            playerView?.stop()
        }
        
    }
    
}

#Preview {
    ExampleView()
}

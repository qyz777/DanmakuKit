//
//  DanmakuViewAdapter.swift
//  DanmakuKit
//
//  Created by QiYiZhong on 2024/1/31.
//

import SwiftUI

@available(iOS 14.0, tvOS 14.0, *)
public struct DanmakuViewAdapter: UIViewRepresentable {
    
    public typealias UIViewType = DanmakuView
    
    @ObservedObject var coordinator: Coordinator
    
    public init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        return coordinator.makeView()
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        return coordinator
    }
    
    public class Coordinator: ObservableObject {
        
        public init() {}
        
        public private(set) var danmakuView: DanmakuView?
        
        private var frameObserver: Any?
        
        public weak var danmakuViewDelegate: DanmakuViewDelegate? {
            willSet {
                danmakuView?.delegate = newValue
            }
        }
        
        public func play() {
            danmakuView?.play()
        }
        
        public func pause() {
            danmakuView?.pause()
        }
        
        public func stop() {
            danmakuView?.stop()
        }
        
        public func clean() {
            danmakuView?.clean()
        }
        
        public func shoot(danmaku: DanmakuCellModel) {
            danmakuView?.shoot(danmaku: danmaku)
        }
        
        public func canShoot(danmaku: DanmakuCellModel) -> Bool {
            guard let view = danmakuView else { return false }
            return view.canShoot(danmaku: danmaku)
        }
        
        public func recalculateTracks() {
            danmakuView?.recalculateTracks()
        }
        
        public func sync(danmaku: DanmakuCellModel, at progress: Float) {
            danmakuView?.sync(danmaku: danmaku, at: progress)
        }
        
        func makeView() -> DanmakuView {
            danmakuView = DanmakuView(frame: .zero)
            frameObserver = danmakuView?.publisher(for: \.frame).sink { [weak self] _ in
                guard let self = self else { return }
                self.danmakuView?.recalculateTracks()
            }
            return danmakuView!
        }
        
    }
    
}

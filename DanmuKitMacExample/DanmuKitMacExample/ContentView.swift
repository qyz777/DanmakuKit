//
//  ContentView.swift
//  DanmuKitMacExample
//
//  Created by 常超群 on 2025/8/23.
//

import SwiftUI
import DanmakuKit

// Lightweight FPS monitor for macOS using CVDisplayLink
import AppKit
final class FPSMonitor: ObservableObject {
    @Published var fps: Double = 0
    private var displayLink: CVDisplayLink?
    private var lastTimestamp: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    private var frameCount: Int = 0
    func start() {
        guard displayLink == nil else { return }
        var link: CVDisplayLink?
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        guard let link else { return }
        displayLink = link
        let callback: CVDisplayLinkOutputCallback = { _,_,_,_,_,userInfo in
            guard let userInfo else { return kCVReturnSuccess }
            let monitor = Unmanaged<FPSMonitor>.fromOpaque(userInfo).takeUnretainedValue()
            monitor.tick()
            return kCVReturnSuccess
        }
        CVDisplayLinkSetOutputCallback(link, callback, Unmanaged.passUnretained(self).toOpaque())
        CVDisplayLinkStart(link)
    }
    func stop() {
        guard let link = displayLink else { return }
        CVDisplayLinkStop(link)
        displayLink = nil
        DispatchQueue.main.async { [weak self] in self?.fps = 0 }
        frameCount = 0
        lastTimestamp = CFAbsoluteTimeGetCurrent()
    }
    private func tick() {
        frameCount += 1
        let now = CFAbsoluteTimeGetCurrent()
        let delta = now - lastTimestamp
        if delta >= 1.0 {
            let currentFPS = Double(frameCount) / delta
            frameCount = 0
            lastTimestamp = now
            DispatchQueue.main.async { [weak self] in self?.fps = currentFPS }
        }
    }
}

struct ContentView: View {
    @StateObject private var coordinator = DanmakuViewAdapter.Coordinator()
    @State private var timer: Timer?
    @State private var danmakuIndex = 0
    @State private var isOverlap = false
    @State private var playingSpeed: Double = 1.0
    @State private var delegateRef: DanmakuDelegate? = nil // strong ref to avoid immediate deallocation warning
    @StateObject private var fpsMonitor = FPSMonitor()

    private let sampleTexts = [
        "欢迎来到macOS弹幕世界！",
        "这是一个测试弹幕",
        "支持多种弹幕类型",
        "浮动弹幕从右到左",
        "顶部弹幕固定显示",
        "底部弹幕也很酷",
        "弹幕可以重叠显示",
        "支持不同颜色和字体",
        "macOS弹幕库移植成功！",
        "点击弹幕试试看"
    ]

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("DanmakuKit macOS Example")
                .font(.title)
                .fontWeight(.bold)

            // Danmaku View
            ZStack(alignment: .topLeading) {
                DanmakuViewAdapter(coordinator: coordinator) {
                    Rectangle()
                        .fill(.blue)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contextMenu {
                            Text("Context_Menu")
                        }
                        .onTapGesture(count: 2) {
                            print("[Adapter] InnerView tapped")
                        }
                }
                .frame(minWidth: 400, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
                .background(Color.black)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.purple, lineWidth: 1)
                )

                // FPS overlay
                Text("FPS: \(Int(round(fpsMonitor.fps)))")
                    .font(.system(size: 12, weight: .bold))
                    .padding(6)
                    .background(Color.black.opacity(0.6))
                    .foregroundColor(.green)
                    .cornerRadius(6)
                    .padding(8)
            }

            // Control Buttons
            HStack(spacing: 10) {
                Button("Play") {
                    playButtonClicked()
                }
                .buttonStyle(.borderedProminent)

                Button("Pause") {
                    pauseButtonClicked()
                }
                .buttonStyle(.bordered)

                Button("Stop") {
                    stopButtonClicked()
                }
                .buttonStyle(.bordered)

                Button("Shoot") {
                    shootButtonClicked()
                }
                .buttonStyle(.bordered)

                Button("Clean") {
                    cleanButtonClicked()
                }
                .buttonStyle(.bordered)
            }

            // Settings
            HStack(spacing: 20) {
                Toggle("Overlap", isOn: $isOverlap)
                    .onChange(of: isOverlap) { newValue in
                        coordinator.danmakuView?.isOverlap = newValue
                        print("Overlap mode: \(newValue)")
                    }

                VStack {
                    Text("Speed: \(String(format: "%.1f", playingSpeed))x")
                    Slider(value: $playingSpeed, in: 0.5...3.0, step: 0.1)
                        .frame(width: 200)
                        .onChange(of: playingSpeed) { newValue in
                            coordinator.danmakuView?.playingSpeed = Float(newValue)
                            print("Speed changed to: \(newValue)")
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onAppear {
            setupDanmakuView()
            setupTimer()
            fpsMonitor.start()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
            fpsMonitor.stop()
        }
    }

    // MARK: - Private Methods
    private func setupDanmakuView() {
        // Keep a strong reference to delegate to avoid immediate deallocation
        let delegate = DanmakuDelegate()
        self.delegateRef = delegate
        coordinator.danmakuViewDelegate = delegate

        // Configure danmaku view settings
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            coordinator.danmakuView?.enableCellReusable = true
            coordinator.danmakuView?.trackHeight = 20
            coordinator.danmakuView?.isOverlap = isOverlap
            coordinator.danmakuView?.playingSpeed = Float(playingSpeed)
        }
    }

    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            shootRandomDanmaku()
        }
    }

    private func shootRandomDanmaku() {
        guard coordinator.danmakuView?.status == .play else { return }

        let text = sampleTexts[danmakuIndex % sampleTexts.count]
        danmakuIndex += 1

        let model = DanmakuTextCellModel(text: text)

        // 随机选择弹幕类型：浮动、顶部、底部
        let danmakuTypes: [DanmakuCellType] = [.floating, .top, .bottom]
        let randomType = danmakuTypes.randomElement() ?? .floating
        model.type = randomType

        // 根据弹幕类型设置不同的样式
        switch randomType {
        case .floating:
            model.textColor = .white
            model.font = .systemFont(ofSize: 16)
        case .top:
            model.textColor = .systemYellow
            model.font = .boldSystemFont(ofSize: 18)
        case .bottom:
            model.textColor = .systemGreen
            model.font = .boldSystemFont(ofSize: 18)
        }

        // 开启黑色描边
        model.strokeColor = .black
        model.strokeWidth = 0.0
        model.strokeOpacity = 0.0

        // 轻阴影增加可读性
        model.shadowColor = .black
        model.shadowOpacity = 0.4
        model.shadowBlur = 1.5
        model.shadowOffset = CGSize(width: 1, height: 1)

        model.calculateSize()

        coordinator.shoot(danmaku: model)
//        print("弹幕出现: \(text) - 类型: \(randomType)")
    }

    // MARK: - Button Actions
    private func playButtonClicked() {
        coordinator.play()
        print("Danmaku started playing")
    }

    private func pauseButtonClicked() {
        coordinator.pause()
        print("Danmaku paused")
    }

    private func stopButtonClicked() {
        coordinator.stop()
        timer?.invalidate()
        timer = nil
        setupTimer()
        print("Danmaku stopped")
    }

    private func shootButtonClicked() {
        let text = "手动发射的弹幕 #\(danmakuIndex)"
        danmakuIndex += 1

        let model = DanmakuTextCellModel(text: text)

        // 手动发射时也随机选择弹幕类型
        let danmakuTypes: [DanmakuCellType] = [.floating, .top, .bottom]
        let randomType = danmakuTypes.randomElement() ?? .floating
        model.type = randomType

        // 根据弹幕类型设置不同的样式
        switch randomType {
        case .floating:
            model.textColor = .systemBlue
            model.font = .boldSystemFont(ofSize: 16)
        case .top:
            model.textColor = .systemOrange
            model.font = .boldSystemFont(ofSize: 18)
            model.displayTime = 4.0
        case .bottom:
            model.textColor = .systemPurple
            model.font = .boldSystemFont(ofSize: 18)
            model.displayTime = 4.0
        }

        model.calculateSize()

        coordinator.shoot(danmaku: model)
        print("Manual danmaku shot: \(text) - 类型: \(randomType)")
    }

    private func cleanButtonClicked() {
        coordinator.clean()
        print("Danmaku cleaned")
    }
}

// MARK: - DanmakuViewDelegate
class DanmakuDelegate: DanmakuViewDelegate {

    func danmakuView(_ danmakuView: DanmakuView, willDisplay danmaku: DanmakuCell) {
        print("Will display danmaku: \((danmaku.model as? DanmakuTextCellModel)?.text ?? "unknown")")
    }

    func danmakuView(_ danmakuView: DanmakuView, didEndDisplaying danmaku: DanmakuCell) {
         print("Did end displaying danmaku: \((danmaku.model as? DanmakuTextCellModel)?.text ?? "unknown")")
    }

    func danmakuView(_ danmakuView: DanmakuView, didTapped danmaku: DanmakuCell) {
        let text = (danmaku.model as? DanmakuTextCellModel)?.text ?? "unknown"
        print("Danmaku tapped: \(text)")
    }

    func danmakuView(_ danmakuView: DanmakuView, noSpaceShoot danmaku: DanmakuCellModel) {
        print("No space to shoot danmaku: \((danmaku as? DanmakuTextCellModel)?.text ?? "unknown")")
    }

    func danmakuView(_ danmakuView: DanmakuView, dequeueReusable danmaku: DanmakuCell) {
        print("Reusing danmaku cell")
    }
    
    func danmakuView(_ danmakuView: DanmakuView, didHovered danmaku: DanmakuCell) {
        if let model = danmaku.model {
            danmakuView.pause(model)
        }
    }

    func danmakuView(_ danmakuView: DanmakuView, stopHovered danmaku: DanmakuCell) {
        if let model = danmaku.model {
            danmakuView.play(model)
        }
    }
}

// MARK: - DanmakuCellType Extension
extension DanmakuCellType: CaseIterable {
    public static var allCases: [DanmakuCellType] {
        return [.floating, .top, .bottom]
    }
}

#Preview {
    ContentView()
}

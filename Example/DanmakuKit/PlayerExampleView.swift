//
//  ExampleView.swift
//  DanmakuKit_Example
//
//  Created by QiYiZhong on 2024/1/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct PlayerExampleView: View {
    var body: some View {
        VideoPlayer(videoModel: VideoModel(url: Bundle.main.url(forResource: "demo", withExtension: "MOV")?.absoluteString ?? "", title: "Demo")) { _ in }
    }
}

#Preview {
    PlayerExampleView()
}

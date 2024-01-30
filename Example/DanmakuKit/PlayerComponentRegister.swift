//
//  PlayerComponentRegister.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2023/3/12.
//

import Foundation

class PlayerComponentRegister {
    
    static func register(center: ComponentCenter) {
        center.register(PlayerControlComponent.self)
        center.register(DanmakuComponent.self)
    }

}

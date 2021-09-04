//
//  TestDanmakuCellModel.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2021/8/31.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

protocol TestDanmakuCellModel {
    
    var isPause: Bool { get set }
    
    var displayTime: Double { get set }
    
    var offsetTime: TimeInterval { get set }
    
    func calculateSize()
    
}

extension TestDanmakuCellModel {
    
    func calculateSize() {}
    
}

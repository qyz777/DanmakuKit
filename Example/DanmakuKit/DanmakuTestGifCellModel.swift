//
//  DanmakuTestGifCellModel.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2021/8/31.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import DanmakuKit

class DanmakuTestGifCellModel: DanmakuGifCellModel, TestDanmakuCellModel, Equatable {
    
    var resource: Data? {
        guard let url = Bundle.main.url(forResource: "test", withExtension: "gif") else { return nil }
        return try? Data(contentsOf: url)
    }
    
    var identifier = ""
    
    var text = ""
    
    var font = UIFont.systemFont(ofSize: 15)
    
    var offsetTime: TimeInterval = 0
    
    var cellClass: DanmakuCell.Type {
        return DanmakuGifCell.self
    }
    
    var size: CGSize = .zero
    
    var track: UInt?
    
    var displayTime: Double = 8
    
    var type: DanmakuCellType = .floating
    
    var isPause: Bool = false
    
    static func == (lhs: DanmakuTestGifCellModel, rhs: DanmakuTestGifCellModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func isEqual(to cellModel: DanmakuCellModel) -> Bool {
        return identifier == cellModel.identifier
    }
    
}

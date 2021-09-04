//
//  DanmakuTestGifCellModel.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2021/8/31.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import DanmakuKit
import SwiftyJSON

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
    
    func calculateSize() {
        size = CGSize(width: 20, height: 20)
    }
    
    init(json: JSON?) {
        guard let json = json else { return }
        text = json["text"].stringValue
        switch json["type"].intValue {
        case 0:
            type = .floating
        case 1:
            type = .top
        case 2:
            type = .bottom
        default:
            type = .floating
        }
        offsetTime = json["offset_time"].doubleValue
    }
    
    init() {}
    
}

//
//  DanmakuTextCellModel.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2020/8/29.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import DanmakuKit

class DanmakuTextCellModel: DanmakuCellModel {
    
    var text = ""
    
    var cellClass: DanmakuCell.Type {
        return DanmakuTextCell.self
    }
    
    var nameSpace: String?
    
    var size: CGSize {
        return CGSize(width: 100, height: 20)
    }
    
    var track: UInt?
    
    var displayTime: Double {
        return 8
    }
    
    var type: DanmakuCellType {
        return .floating
    }
    
    func calculateSize() {
        
    }
    
}

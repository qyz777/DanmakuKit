//
//  DanmakuGifCellModel.swift
//  DanmakuKit
//
//  Created by Q YiZhong on 2021/8/31.
//

import Foundation

public protocol DanmakuGifCellModel: DanmakuCellModel {
    
    /// GIF data source
    var resource: Data? { get }
    
}

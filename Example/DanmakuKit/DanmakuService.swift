//
//  DanmakuService.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2020/10/3.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftyJSON

class DanmakuService {
    
    func request(_ closure: @escaping(_ json: JSON) -> Void) {
        guard let url = Bundle.main.url(forResource: "danmaku", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: url, options: .dataReadingMapped)
            let json = try JSON(data: data)
            closure(json)
        } catch {
            return
        }
    }
    
}

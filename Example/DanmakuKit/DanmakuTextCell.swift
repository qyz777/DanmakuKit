//
//  DanmakuTextCell.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2020/8/29.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import DanmakuKit

class DanmakuTextCell: DanmakuCell {

    required init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willDisplay() {
        
    }
    
    override func displaying(_ context: CGContext, _ size: CGSize, _ isCancelled: Bool) {
        guard let model = model as? DanmakuTextCellModel else { return }
        let text = NSString(string: model.text)
        let attributes: [NSAttributedStringKey: Any] = [.font: model.font, .foregroundColor: UIColor.red]
        text.draw(at: .zero, withAttributes: attributes)
    }
    
    override func didDisplay(_ finished: Bool) {
        
    }
    
}

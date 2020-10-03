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
        context.setLineWidth(1)
        context.setLineJoin(.round)
        context.setStrokeColor(UIColor.white.cgColor)
        context.saveGState()
        context.setTextDrawingMode(.stroke)
        let attributes: [NSAttributedString.Key: Any] = [.font: model.font, .foregroundColor: UIColor.white]
        text.draw(at: .zero, withAttributes: attributes)
        context.restoreGState()
        
        context.setTextDrawingMode(.fill)
        text.draw(at: .zero, withAttributes: attributes)
    }
    
    override func didDisplay(_ finished: Bool) {
        
    }
    
}

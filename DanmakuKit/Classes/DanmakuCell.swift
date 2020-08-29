//
//  DanmakuCell.swift
//  DanmakuKit
//
//  Created by Q YiZhong on 2020/8/16.
//

import UIKit

public class DanmakuCell: UIView {

    public var model: DanmakuCellModel?
    
    public override class var layerClass: AnyClass {
        return DanmakuAsyncLayer.self
    }
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public extension DanmakuCell {
    
    func willDisplay() {
        
    }
    
    func displaying(_ context: CGContext, _ size: CGSize, _ isCancelled: Bool) {
        
    }
    
    func didDisplay(_ finished: Bool) {
        
    }
    
}

extension DanmakuCell {
    
    var realFrame: CGRect {
        if layer.presentation() != nil {
            return layer.presentation()!.frame
        } else {
            return frame
        }
    }
    
    func setupLayer() {
        guard let layer = layer as? DanmakuAsyncLayer else { return }
        
        layer.willDisplay = { [weak self] (layer) in
            guard let strongSelf = self else { return }
            strongSelf.willDisplay()
        }
        
        layer.displaying = { [weak self] (context, size, isCancelled) in
            guard let strongSelf = self else { return }
            strongSelf.displaying(context, size, isCancelled())
        }
        
        layer.didDisplay = { [weak self] (layer, finished) in
            guard let strongSelf = self else { return }
            strongSelf.didDisplay(finished)
        }
    }
    
}

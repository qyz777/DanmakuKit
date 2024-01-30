//
//  GradientView.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2023/2/26.
//

import UIKit

class GradientView: UIView {
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

}

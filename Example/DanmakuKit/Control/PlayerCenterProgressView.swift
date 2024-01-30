//
//  PlayerCenterProgressView.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2023/3/4.
//

import UIKit

class PlayerCenterProgressView: UIView {
    
    var progress: CGFloat = 0 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trackView.left = imageView.right + 4
        trackView.center.y = height / 2.0
        progressView.left = trackView.left
        progressView.center.y = height / 2.0
        
        progressView.width = 150 * progress
    }
    
    private func setupSubview() {
        addSubview(imageView)
        addSubview(trackView)
        addSubview(progressView)
    }
    
    lazy var imageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        return view
    }()
    
    lazy var trackView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 4))
        view.layer.cornerRadius = 2
        view.alpha = 0.2
        view.backgroundColor = .white
        return view
    }()
    
    lazy var progressView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 4))
        view.layer.cornerRadius = 1
        view.backgroundColor = .white
        return view
    }()

}

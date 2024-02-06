![DanmakuKit](./Images/DanmakuKit.png)

[![Version](https://img.shields.io/cocoapods/v/DanmakuKit.svg?style=flat)](https://cocoapods.org/pods/DanmakuKit)
[![License](https://img.shields.io/cocoapods/l/DanmakuKit.svg?style=flat)](https://cocoapods.org/pods/DanmakuKit)
[![Platform](https://img.shields.io/cocoapods/p/DanmakuKit.svg?style=flat)](https://cocoapods.org/pods/DanmakuKit)

# DanmakuKit

## 介绍

DanmakuKit是一个高性能弹幕框架，提供了弹幕相关的基础功能。它提供了一系列操作能够允许你通过cellModel来生成弹幕，并且每个弹幕都支持同步或异步渲染。

[中文博客](https://juejin.cn/post/6880412928592314376)

如下GIF所示，DanmakuKit提供三种类型的弹幕：悬浮、置顶和置地。

![Demo_0](https://raw.githubusercontent.com/qyz777/resource/master/danmakukit_demo_0.gif) 

![Demo_1](https://raw.githubusercontent.com/qyz777/resource/master/danmakukit_demo_1.gif)



### Supported features

- [x] 速度调节
- [x] 轨道高度调节
- [x] 显示区域调节
- [x] 点击回调 
- [x] 暂停和播放单条弹幕
- [x] 弹幕重叠或非重叠状态
- [x] 针对不同类型的轨道禁用弹幕
- [x] 设置弹幕播放进度
- [x] 清理所有弹幕
- [x] Gif弹幕
- [x] SwiftUI

## 使用指南

### 弹幕绘制

1. 实现一个从DanmakuCellModel继承的cellModel。在这个cellModel中需要添加自己的属性和方法来画出弹幕。

```swift
class DanmakuTextCellModel: DanmakuCellModel {
    var identifier = ""
    
    var text = ""
    
    var font = UIFont.systemFont(ofSize: 15)
    
    var offsetTime: TimeInterval = 0
    
    var cellClass: DanmakuCell.Type {
        return DanmakuTextCell.self
    }
    
    var size: CGSize = .zero
    
    var track: UInt?
    
    var displayTime: Double = 8
    
    var type: DanmakuCellType = .floating
    
    var isPause = false
    
    func calculateSize() {
        size = NSString(string: text).boundingRect(with: CGSize(width: CGFloat(Float.infinity
            ), height: 20), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [.font: font], context: nil).size
    }
    
    func isEqual(to cellModel: DanmakuCellModel) -> Bool {
        return identifier == cellModel.identifier
    }
}
```

2. 实现一个继承DanmakuCell的View。接着实现`displaying`方法，并使用CGContext来绘制弹幕。需要注意的是，`displaying`方法的调用并不会在主线程，所以你需要考虑多线程问题。

```swift
class DanmakuTextCell: DanmakuCell {
    required init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}
```

3. 给DanmakuView传DanmakuCellModel来显示弹幕。

```swift
let danmakuView = DanmakuView(frame: CGRect(x: 0, y: 0, width: 350, height: 250))
view.addSubview(danmakuView)
let cellModel = DanmakuTextCellModel(json: nil)
cellModel.displayTime = displayTime
cellModel.text = contents[index]
cellModel.identifier = String(arc4random())
cellModel.calculateSize()
cellModel.type = .floating
danmakuView.shoot(danmaku: cellModel)
```

### 播放弹幕

调用play()方法开始显示弹幕。

```swift
danmakuView.play()
```

调用pause()方法暂停弹幕播放。

```swift
danmakuView.pause()
```

调用stop()方法来停止展示弹幕并清理资源。与DanmakuKit相关的内存在该方法调用前不会释放。该方法会在DanmakuView销毁时调用。

```swift
danmakuView.stop()
```

### Gif弹幕

如果想要在弹幕上展示Gif，可以引入Gif subspec并使用DanmakuGifCell和DanmakuGifCellModel。

### 更多功能

查看Example工程来了解更多功能。


## 使用要求

swift 5.0+

iOS 10.0+, SwiftUI iOS 14.0+

## 安装

DanmakuKit通过[CocoaPods](https://cocoapods.org)安装。添加如下代码到你的Podfile文件中即可安装。

```ruby
pod 'DanmakuKit', '~> 1.5.0'
```

### Swift Package Manager

DanmakuKit也支持通过[Swift Package Manager](https://github.com/apple/swift-package-manager). 添加如下代码到你的Package.Swift即可安装:

```
dependencies: [
    .package(url: "https://github.com/qyz777/DanmakuKit.git", from: "1.5.0"),
],
targets: [
    .target( name: "YourTarget", dependencies: ["DanmakuKit"]),
]
```

## 许可证

DanmakuKit使用MIT许可证，请查看LICENSE文件了解更多信息。
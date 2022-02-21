![DanmakuKit](./Images/DanmakuKit.png)

[![Version](https://img.shields.io/cocoapods/v/DanmakuKit.svg?style=flat)](https://cocoapods.org/pods/DanmakuKit)
[![License](https://img.shields.io/cocoapods/l/DanmakuKit.svg?style=flat)](https://cocoapods.org/pods/DanmakuKit)
[![Platform](https://img.shields.io/cocoapods/p/DanmakuKit.svg?style=flat)](https://cocoapods.org/pods/DanmakuKit)

# DanmakuKit([中文](./README_CN.md))

## Introduction

DanmakuKit is a high performance library that provides the basic functions of danmaku. It provides a set of processes that allow you to generate the danmaku cell via cellModel, and each danmaku can be drawn either synchronously or asynchronously. 

[中文博客](https://juejin.cn/post/6880412928592314376)

As shown in the GIF below, DanmakuKit offers three types of danmaku launch: floating, top and bottom.

![Demo_0](https://raw.githubusercontent.com/qyz777/resource/master/danmakukit_demo_0.gif) 

![Demo_1](https://raw.githubusercontent.com/qyz777/resource/master/danmakukit_demo_1.gif)



### Supported features

- [x] Speed adjustment
- [x] Track height adjustment
- [x] Display area adjustment
- [x] Click callback 
- [x] Support to pause or play a single danmaku
- [x] Provides property to specify whether danmaku can overlap
- [x] Support to disable danmaku for different types of tracks
- [x] Support for setting progress property to render the danmaku immediately on the view
- [x] Support to clean up all danmaku
- [x] Support Gif Danmaku

## Use Guide

### Draw Danmaku

1. Implement a model to inherit from the DanmakuCellModel. In this model you need to add your own properties and methods to draw the danmaku.

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

2. Implement a View inherited from DanmakuCell. Then you need to override the `displaying` method, and use CGContext draw your danmaku. **It is important to note when call `displaying` method was not in the main thread, so you need to consider multithreading.** 

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

3. Pass the DanmakuCellModel to the DanmakuView to display danmaku.

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

### Play Danmaku

Call play() method to start display danmaku.

```swift
danmakuView.play()
```

Call pause() method to pause the play of danmaku.

```swift
danmakuView.pause()
```

Call stop() method to stop display danmaku and clean up resource. The memory associated with DanmakuKit is not cleaned up until this method is called. This method will be invoked when DanmakuView destroyed.

```swift
danmakuView.stop()
```

### Gif Danmaku

If you want to display GIF on a danmaku, then import the Gif subspec and use the DanmakuGifCell and DanmakuGifCellModel.

### Other Features

See the Example project for more features.


## Requirements

swift 5.0+

iOS 9.0+

## Installation

DanmakuKit is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'DanmakuKit', '~> 1.3.0'
```

## License

DanmakuKit is available under the MIT license. See the LICENSE file for more info.

# DanmakuKit

[![Version](https://img.shields.io/cocoapods/v/DanmakuKit.svg?style=flat)](https://cocoapods.org/pods/DanmakuKit)
[![License](https://img.shields.io/cocoapods/l/DanmakuKit.svg?style=flat)](https://cocoapods.org/pods/DanmakuKit)
[![Platform](https://img.shields.io/cocoapods/p/DanmakuKit.svg?style=flat)](https://cocoapods.org/pods/DanmakuKit)

## Introduction

DanmakuKit is a high performance library that provides the basic functions of danmaku. It provides a set of processes that allow you to generate the danmaku cell via cellModel, and each danmaku can be drawn either synchronously or asynchronously. 

[中文博客](https://juejin.cn/post/6880412928592314376)

As shown in the GIF below, DanmakuKit offers three types of danmaku launch: floating, top and bottom.

![Demo_0](./Images/demo_0.gif) 

![Demo_1](./Images/demo_1.gif)



### Supported features

- [x] Speed adjustment
- [x] Track height adjustment
- [x] Display area adjustment
- [x] Click callback 
- [x] Support to pause or play a single danmaku
- [x] Provides property to specify whether danmaku can overlap
- [x] Support to disable danmaku for different types of tracks
- [x] Support for setting progress property to render the danmaku immediately on the view
- [x] Support to clear all danmaku
- [x] Support playing speed

### TODO

**If you have any requirements that you want DanmakuKit to provide, you can raise issue.**

- [ ] Support mask danmaku


## Example

For detailed usage, see the Example project, which provides a functional demonstration and an example of using it with a player. 

## Use Guide

1. Implement a model to inherit from the DanmakuCellModel. In this model you need to add your own properties and methods to draw the danmaku.
2. Implement a View inherited from DanmakuCell. Override the `willDisplay` method to prepare a thread-safe model for drawing a danmaku. Then you need to override the `displaying` method, and use CGContext draw your danmaku. **It is important to note when call `displaying` method was not in the main thread, so you need to consider multithreading.** And finally, if you also need to do something at the end of the drawing, you can override the `didDisplay` method to do that.
3. Pass the DanmakuCellModel to the DanmakuView so that it will fire the danmaku for you.


## Requirements

swift 5.0+

iOS 9.0+

## Installation

DanmakuKit is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'DanmakuKit', '~> 1.2.1'
```

## License

DanmakuKit is available under the MIT license. See the LICENSE file for more info.
//
//  PlatformTypes.swift
//  DanmakuKit
//
//  Created by chaoqun Agent on 2025/8/23.
//  Platform-specific type aliases for cross-platform compatibility
//

import Foundation

#if os(macOS)
import AppKit
import SwiftUI
public typealias PlatformView = NSView
public typealias PlatformScreen = NSScreen
public typealias PlatformColor = NSColor
public typealias PlatformPoint = NSPoint
@available(macOS 10.15, *)
public typealias PlatformViewRepresentable = NSViewRepresentable
#else
import UIKit
import SwiftUI
public typealias PlatformView = UIView
public typealias PlatformScreen = UIScreen
public typealias PlatformColor = UIColor
public typealias PlatformPoint = CGPoint
@available(iOS 13.0, tvOS 13.0, *)
public typealias PlatformViewRepresentable = UIViewRepresentable
#endif

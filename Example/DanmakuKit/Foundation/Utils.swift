//
//  Utils.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2023/2/18.
//

import Foundation
import UIKit
import SwiftUI

func logDebug(_ items: Any...) {
    #if DEBUG
    print(items)
    #endif
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemUltraThinMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        view.isUserInteractionEnabled = false
        return view
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct NavigationAdapter<Label>: View where Label: View {
    
    @ViewBuilder var label: () -> Label
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                label()
            }
        } else {
            NavigationView {
                label()
            }
        }
    }
}

struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

private struct SafeAreaInsetsKey: EnvironmentKey {
    
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero).insets
    }
    
}

private extension UIEdgeInsets {
    
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
    
}

extension EnvironmentValues {
    
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

class ExpandTouchView: UIView {
    
    public var hitTestEdgeInsets: UIEdgeInsets?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let insets = hitTestEdgeInsets, insets != .zero, !isHidden {
            let area = bounds.inset(by: insets)
            return area.contains(point)
        }
        return super.point(inside: point, with: event)
    }
    
}

class ExpandTouchButton: UIButton {
    
    public var hitTestEdgeInsets: UIEdgeInsets?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let insets = hitTestEdgeInsets, insets != .zero, !isHidden {
            let area = bounds.inset(by: insets)
            return area.contains(point)
        }
        return super.point(inside: point, with: event)
    }
    
}

extension Int64 {
    
    var dataSizeString: String {
        if self >= 1024 * 1024 * 1024 {
            return String(format: "%.1lldGB", self / 1024 / 1024 / 1024)
        } else if self >= 1024 * 1024 {
            return String(format: "%.1lldMB", self / 1024 / 1024)
        } else {
            return String(format: "%.1lldKB", self / 1024)
        }
    }
    
}

extension Date {
    
    var dayString: String {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: self)
    }
    
    var isToday: Bool {
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.day, .month, .year]
        let nowComps = calendar.dateComponents(unit, from: Date())
        let selfComps = calendar.dateComponents(unit, from: self)
        return (selfComps.year == nowComps.year) && (selfComps.month == nowComps.month) && (selfComps.day == nowComps.day)
    }
    
    var isYesterday: Bool {
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.day, .month, .year]
        let nowComps = calendar.dateComponents(unit, from: Date())
        let selfComps = calendar.dateComponents(unit, from: self)
        if selfComps.day == nil || nowComps.day == nil {
            return false
        }
        let count = nowComps.day! - selfComps.day!
        return (selfComps.year == nowComps.year) && (selfComps.month == nowComps.month) && (count == 1)
    }
    
}

extension UIApplication {
    
    static var isLandscape: Bool {
        return UIApplication.shared.keyWindow?.windowScene?.interfaceOrientation.isLandscape ?? false
    }
    
    static var isPortrait: Bool {
        return UIApplication.shared.keyWindow?.windowScene?.interfaceOrientation.isPortrait ?? false
    }
    
    static var interface: UIInterfaceOrientation {
        return UIApplication.shared.keyWindow?.windowScene?.interfaceOrientation ?? .unknown
    }
    
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first {
                $0.isKeyWindow
            }
    }
    
}

extension UIView {
    
    var width: CGFloat {
        set {
            frame.size = CGSize(width: newValue, height: frame.height)
        }
        get {
            return frame.width
        }
    }
    
    var height: CGFloat {
        set {
            frame.size = CGSize(width: frame.width, height: newValue)
        }
        get {
            return frame.height
        }
    }
    
    var left: CGFloat {
        set {
            frame = CGRect(x: newValue, y: top, width: width, height: height)
        }
        get {
            return frame.minX
        }
    }
    
    var right: CGFloat {
        set {
            frame = CGRect(x: newValue - width, y: top, width: width, height: height)
        }
        get {
            return frame.maxX
        }
    }
    
    var top: CGFloat {
        set {
            frame = CGRect(x: left, y: newValue, width: width, height: height)
        }
        get {
            return frame.minY
        }
    }
    
    var bottom: CGFloat {
        set {
            frame = CGRect(x: left, y: newValue - height, width: width, height: height)
        }
        get {
            return frame.maxY
        }
    }
    
    func hidden(afterDelay delay: TimeInterval) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenDelay), object: nil)
        perform(#selector(hiddenDelay), with: nil, afterDelay: delay, inModes: [.common])
    }
    
    @objc private func hiddenDelay() {
        isHidden = true
    }
    
}

extension UIImage {
    
    func resizeImage(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
     
    
    func scaleImage(to rate: CGFloat) -> UIImage? {
        let size = CGSize(width: size.width * rate, height: size.height * rate)
        return resizeImage(to: size)
    }
}

extension Double {
    
    func calculateTimeString(overOneHour: Bool = false) -> String {
        var timeString = ""
        let durationS = Int(self)
        let s = durationS % 60
        let durationM = (durationS - s) / 60
        let m = durationM % 60
        let h = (durationM - m) / 60
        
        if h > 0 || overOneHour {
            if h < 10 {
                timeString.append("0\(h)")
            } else {
                timeString.append("\(h)")
            }
            timeString.append(":")
        }
        
        if m > 0 {
            if m < 10 {
                timeString.append("0\(m)")
            } else {
                timeString.append("\(m)")
            }
        } else {
            timeString.append("00")
        }
        timeString.append(":")
        
        if s > 0 {
            if s < 10 {
                timeString.append("0\(s)")
            } else {
                timeString.append("\(s)")
            }
        } else {
            timeString.append("00")
        }
        
        return timeString
    }
    
}

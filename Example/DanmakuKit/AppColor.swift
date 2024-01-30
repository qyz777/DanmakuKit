//
//  AppColor.swift
//  DanmakuKit_Example
//
//  Created by Q YiZhong on 2023/4/10.
//

import UIKit
import SwiftUI

extension UIColor {
    
    static let highlight = UIColor(hex: "#CD0958")
    
    static let textColor = UIColor(light: .black, dark: .white)
    
    static let background = UIColor(lightHex: "#f8f8fa", darkHex: "#35363a")
    
    static let background2 = UIColor(lightHex: "#fdfdfd", darkHex: "#202124")
    
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    convenience init(lightHex: String, darkHex: String) {
        self.init(light: UIColor(hex: lightHex), dark: UIColor(hex: darkHex))
    }
    
    convenience init(light: UIColor, dark: UIColor) {
        self.init {
            switch $0.userInterfaceStyle {
            case .light, .unspecified:
                return light
            case .dark:
                return dark
            default:
                return light
            }
        }
    }
    
}

extension Color {
    
    static let highlight = Color(hex: "#CD0958")
    
    static let textColor = Color(light: .black, dark: .white)
    
    static let infoTextColor = Color(lightHex: "#8a898e", darkHex: "#9e9ea7")
    
    static let background = Color(lightHex: "#f8f8fa", darkHex: "#35363a")
    
    static let background2 = Color(lightHex: "#fdfdfd", darkHex: "#202124")
    
    static let disableColor = Color(light: .gray, dark: Color(UIColor.lightGray))
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    init(lightHex: String, darkHex: String) {
        self.init(light: Color(hex: lightHex), dark: Color(hex: darkHex))
    }
    
    init(light: Color, dark: Color) {
        self.init(UIColor(light: UIColor(light), dark: UIColor(dark)))
    }
    
}

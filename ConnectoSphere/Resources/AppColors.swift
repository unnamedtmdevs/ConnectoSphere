//
//  AppColors.swift
//  ConnectoSphere
//
//

import SwiftUI

struct AppColors {
    // Background colors
    static let primaryBackground = Color(hex: "ae2d27")
    static let secondaryBackground = Color(hex: "dfb492")
    static let tertiaryBackground = Color(hex: "ffc934")
    
    // Element/Button colors
    static let accentGreen = Color(hex: "1ed55f")
    static let accentYellow = Color(hex: "ffff03")
    static let accentRed = Color(hex: "eb262f")
    
    // Glassmorphism overlay
    static let glassOverlay = Color.white.opacity(0.15)
    static let glassBorder = Color.white.opacity(0.3)
}

extension Color {
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
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


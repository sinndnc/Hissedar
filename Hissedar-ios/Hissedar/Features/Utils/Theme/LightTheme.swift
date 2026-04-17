//
//  LightTheme.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/16/26.
//


import SwiftUI

struct LightTheme: AppTheme {
    
    // MARK: - Backgrounds
    // Beyaz/krem zemin, hafif mor tonları ile hiyerarşi
    var background:          Color { Color(hex: "#FAFAFA") }
    var backgroundSecondary: Color { Color(hex: "#FFFFFF") }
    var backgroundTertiary:  Color { Color(hex: "#F3F2F8") }
    var backgroundElevated:  Color { Color(hex: "#FFFFFF") }
    
    // MARK: - Brand Purple Ramp
    // Aynı mor ramp — light temada da marka tutarlılığı korunur
    var purple900: Color { Color(hex: "#5B21B6") }
    var purple800: Color { Color(hex: "#6D28D9") }
    var purple700: Color { Color(hex: "#7C3AED") }
    var purple600: Color { Color(hex: "#8B5CF6") }
    var purple500: Color { Color(hex: "#8B5CF6") }
    var purple400: Color { Color(hex: "#A78BFA") }
    var purple300: Color { Color(hex: "#C4B5FD") }
    var purple200: Color { Color(hex: "#DDD6FE") }
    var purple100: Color { Color(hex: "#EDE9FE") }
    var purple50:  Color { Color(hex: "#F5F3FF") }
    var lavender:      Color { Color(hex: "#7C3AED") }   // Light'ta biraz daha koyu
    var lavenderLight: Color { Color(hex: "#EDE9FE") }
    
    // MARK: - Text
    // Koyu zemin üzerinde iyi kontrast
    var textPrimary:   Color { Color(hex: "#0F0E16") }
    var textSecondary: Color { Color(hex: "#4B4B56") }
    var textTertiary:  Color { Color(hex: "#9A9AA4") }
    
    // MARK: - Semantic
    var accent:          Color { purple700 }             // Light'ta purple700 daha iyi kontrast verir
    var accentSecondary: Color { purple600 }
    var border:          Color { purple700.opacity(0.14) }
    var borderActive:    Color { purple700.opacity(0.40) }
    var success: Color { Color(hex: "#059669") }         // Light için daha koyu yeşil
    var warning: Color { Color(hex: "#D97706") }         // Light için daha koyu sarı
    var error:   Color { Color(hex: "#DC2626") }         // Light için daha koyu kırmızı
    
    // MARK: - Token Parça Renkleri
    var tokenTopLeft:     Color { purple400 }
    var tokenTopRight:    Color { purple700 }
    var tokenBottomLeft:  Color { purple300 }
    var tokenBottomRight: Color { purple800 }
    
    // MARK: - Gradients
    var buttonGradient: LinearGradient {
        LinearGradient(colors: [purple700, purple800],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    var cardGradient: LinearGradient {
        LinearGradient(colors: [backgroundSecondary, backgroundTertiary],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    var avatarGradient: LinearGradient {
        LinearGradient(colors: [purple600, purple800],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
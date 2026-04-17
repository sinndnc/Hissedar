//
//  DarkTheme.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/16/26.
//


import SwiftUI

struct DarkTheme: AppTheme {
    
    // MARK: - Backgrounds
    var background:          Color { Color(hex: "#0A0B0F") }
    var backgroundSecondary: Color { Color(hex: "#181A24") }
    var backgroundTertiary:  Color { Color(hex: "#222430") }
    var backgroundElevated:  Color { Color(hex: "#2A2C3A") }
    
    // MARK: - Brand Purple Ramp
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
    var lavender:      Color { Color(hex: "#C4B5FD") }
    var lavenderLight: Color { Color(hex: "#EDE9FE") }
    
    // MARK: - Text
    var textPrimary:   Color { Color(hex: "#E4E4E8") }
    var textSecondary: Color { Color(hex: "#8A8A92") }
    var textTertiary:  Color { Color(hex: "#4A4A52") }
    
    // MARK: - Semantic
    var accent:          Color { purple600 }
    var accentSecondary: Color { purple400 }
    var border:          Color { purple600.opacity(0.12) }
    var borderActive:    Color { purple600.opacity(0.35) }
    var success: Color { Color(hex: "#34D399") }
    var warning: Color { Color(hex: "#FBBF24") }
    var error:   Color { Color(hex: "#F87171") }
    
    // MARK: - Token Parça Renkleri
    var tokenTopLeft:     Color { lavender }
    var tokenTopRight:    Color { purple600 }
    var tokenBottomLeft:  Color { purple400.opacity(0.7) }
    var tokenBottomRight: Color { purple700 }
    
    // MARK: - Gradients
    var buttonGradient: LinearGradient {
        LinearGradient(colors: [purple600, purple700],
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

//
//  AppTheme.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/16/26.
//

import SwiftUI


protocol AppTheme {
    
    // MARK: - Backgrounds
    var background: Color { get }
    var backgroundSecondary: Color { get }
    var backgroundTertiary: Color { get }
    var backgroundElevated: Color { get }
    
    // MARK: - Brand Purple Ramp
    var purple900: Color { get }
    var purple800: Color { get }
    var purple700: Color { get }
    var purple600: Color { get }
    var purple500: Color { get }
    var purple400: Color { get }
    var purple300: Color { get }
    var purple200: Color { get }
    var purple100: Color { get }
    var purple50: Color { get }
    var lavender: Color { get }
    var lavenderLight: Color { get }
    
    // MARK: - Text
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var textTertiary: Color { get }
    
    // MARK: - Semantic
    var accent: Color { get }
    var accentSecondary: Color { get }
    var border: Color { get }
    var borderActive: Color { get }
    var success: Color { get }
    var warning: Color { get }
    var error: Color { get }
    
    // MARK: - Token Parça Renkleri
    var tokenTopLeft: Color { get }
    var tokenTopRight: Color { get }
    var tokenBottomLeft: Color { get }
    var tokenBottomRight: Color { get }
    
    // MARK: - Gradients
    var buttonGradient: LinearGradient { get }
    var cardGradient: LinearGradient { get }
    var avatarGradient: LinearGradient { get }
}

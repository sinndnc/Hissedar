//
//  Color+Extensions.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import SwiftUI

extension Color {

    // ── Birincil: Forest Green ──────────────────────────
    static let hForest      = Color(hex: "#1A3A2A")   // en koyu — büyük başlıklar
    static let hForestMid   = Color(hex: "#2D5A3F")   // header bg, koyu yüzeyler
    static let hEmerald     = Color(hex: "#2E7D52")   // birincil buton, link
    static let hJade        = Color(hex: "#3DAA6C")   // vurgu, progress, success
    static let hMint        = Color(hex: "#6ECFA0")   // koyu bg üstünde metin
    static let hFoam        = Color(hex: "#C2EDD8")   // açık badge bg
    static let hMist        = Color(hex: "#EAF7EF")   // çok açık yüzey tonu

    // ── Nötr: Obsidian ──────────────────────────────────
    static let hObsidian    = Color(hex: "#0F1A14")   // dark mode bg
    static let hCharcoal    = Color(hex: "#1C2B22")   // dark mode surface
    static let hSlate       = Color(hex: "#2A3D30")   // dark mode border
    static let hAsh         = Color(hex: "#4A5E52")   // muted text
    static let hSilver      = Color(hex: "#8FA99A")   // placeholder, disabled
    static let hCloud       = Color(hex: "#CDD8D2")   // border, divider
    static let hIvory       = Color(hex: "#F4F7F5")   // light mode bg
    static let hWhite       = Color(hex: "#FDFFFE")   // card surface

    // ── Vurgu Renkler ───────────────────────────────────
    static let hGold        = Color(hex: "#C8962A")   // kira geliri, yıllık getiri
    static let hGoldLight   = Color(hex: "#F5E4A8")   // gold badge bg
    static let hRust        = Color(hex: "#E05C3A")   // hata, reddedildi
    static let hSky         = Color(hex: "#3A7CB5")   // blockchain, bilgi

    // ── Semantik (context'e göre ──────────────────────
    static let hSuccess     = Color(hex: "#3DAA6C")   // = hJade
    static let hWarning     = Color(hex: "#C8962A")   // = hGold
    static let hError       = Color(hex: "#E05C3A")   // = hRust
    static let hInfo        = Color(hex: "#3A7CB5")   // = hSky

    // ── Hex init ────────────────────────────────────────
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

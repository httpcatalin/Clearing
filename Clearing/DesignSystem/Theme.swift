import SwiftUI

enum Palette {
    static let accent = Color.accentColor
    static let onAccent = Color(.onAccent)
    static let ink = Color(.ink)
    static let onInk = Color(.onInk)
    static let canvas = Color(.canvas)
    static let space = Color(.space)
    static let glow = Color(.glow)
    static let surface = Color(.surface)
}

enum Typography {
    static let display = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let hero = Font.system(.largeTitle, design: .rounded, weight: .semibold)
    static let number = Font.system(.title2, design: .rounded, weight: .semibold)
    static let counter = Font.system(.subheadline, design: .rounded, weight: .semibold)
    static let brand = Font.system(.headline, design: .rounded, weight: .semibold)
    static let badge = Font.footnote.weight(.bold)
}

enum Spacing {
    static let tight: CGFloat = 8
    static let regular: CGFloat = 16
    static let screen: CGFloat = 24
    static let section: CGFloat = 32
}

enum Radius {
    static let card: CGFloat = 30
    static let slab: CGFloat = 34
    static let markRatio: CGFloat = 0.24
}

enum Motion {
    static let micro = Animation.spring(response: 0.25, dampingFraction: 0.72)
    static let gesture = Animation.spring(response: 0.38, dampingFraction: 0.7)
    static let promote = Animation.spring(response: 0.46, dampingFraction: 0.86)
    static let keep = Animation.spring(response: 0.6, dampingFraction: 0.9)
    static let clear = Animation.easeOut(duration: 0.62)
    static let navigation = Animation.spring(response: 0.55, dampingFraction: 0.92)
    static let reveal = Animation.spring(response: 0.7, dampingFraction: 0.86)
    static let completion = Animation.spring(response: 1.1, dampingFraction: 0.9)
}

enum Haptics {
    static let touch = SensoryFeedback.impact(weight: .light, intensity: 0.5)
    static let threshold = SensoryFeedback.impact(weight: .medium)
    static let keep = SensoryFeedback.impact(flexibility: .soft, intensity: 0.8)
    static let clear = SensoryFeedback.impact(flexibility: .rigid, intensity: 0.7)
    static let open = SensoryFeedback.impact(flexibility: .soft, intensity: 0.6)
    static let complete = SensoryFeedback.success
}

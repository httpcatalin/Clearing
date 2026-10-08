import SwiftUI

enum ReviewChoice {
    case keep
    case clear

    init?(dragWidth: CGFloat) {
        if dragWidth > 0 {
            self = .keep
        } else if dragWidth < 0 {
            self = .clear
        } else {
            return nil
        }
    }

    var title: String {
        self == .keep ? "Keep" : "Clear"
    }


    var color: Color {
        self == .keep ? Palette.ink : Palette.accent
    }

    var onColor: Color {
        self == .keep ? Palette.onInk : Palette.onAccent
    }

    var accessibilityHint: String {
        self == .keep ? "Keeps this photo and shows the next one" : "Clears this photo to make room and shows the next one"
    }
}

struct DecisionButton: View {
    let choice: ReviewChoice
    let emphasis: CGFloat
    var arrivals = 0
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ChoiceGlyph(choice: choice, color: tint)
                    .frame(width: 20, height: 20)

                Text(choice.title)
            }
            .font(.headline)
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background {
                ZStack {
                    Capsule().fill(Palette.surface)
                    Capsule().fill(choice.color).opacity(emphasis)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
        .scaleEffect(1 + 0.05 * emphasis)
        .keyframeAnimator(initialValue: 1.0, trigger: arrivals) { content, scale in
            content.scaleEffect(scale)
        } keyframes: { _ in
            SpringKeyframe(1.07, duration: 0.14)
            SpringKeyframe(1.0, duration: 0.35)
        }
        .accessibilityHint(choice.accessibilityHint)
    }

    private var tint: Color {
        emphasis > 0.55 ? choice.onColor : choice.color
    }
}

struct ChoiceGlyph: View {
    let choice: ReviewChoice
    let color: Color

    var body: some View {
        switch choice {
        case .keep:
            Image(systemName: "checkmark")
                .font(.body.weight(.bold))
                .foregroundStyle(color)
                .accessibilityHidden(true)
        case .clear:
            SplitMark(opening: 0.65, color: color)
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        DecisionButton(choice: .clear, emphasis: 0) {}
        DecisionButton(choice: .keep, emphasis: 0.7) {}
    }
    .padding()
}

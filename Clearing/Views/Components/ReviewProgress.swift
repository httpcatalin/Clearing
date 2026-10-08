import SwiftUI

struct ReviewProgress: View {
    let text: String
    let accessibilityText: String
    let value: Double

    var body: some View {
        HStack(spacing: 10) {
            SplitMark(opening: 0.18 + 0.82 * value)
                .frame(width: 26, height: 26)

            Text(text)
                .font(Typography.counter)
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .animation(Motion.gesture, value: value)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }
}

#Preview {
    VStack(spacing: 20) {
        ReviewProgress(text: "1 / 12", accessibilityText: "Photo 1 of 12", value: 0)
        ReviewProgress(text: "7 / 12", accessibilityText: "Photo 7 of 12", value: 0.5)
        ReviewProgress(text: "12 / 12", accessibilityText: "Photo 12 of 12", value: 0.92)
    }
}

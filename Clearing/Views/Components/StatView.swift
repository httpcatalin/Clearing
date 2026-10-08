import SwiftUI

struct StatView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(Typography.number)
                .monospacedDigit()
                .contentTransition(.numericText())

            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

struct StatRow<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 32) {
                content
            }
            VStack(alignment: .leading, spacing: 14) {
                content
            }
        }
    }
}

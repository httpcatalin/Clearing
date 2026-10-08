import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String

    @State private var isSettled = false

    var body: some View {
        VStack(spacing: Spacing.screen) {
            SplitMark(opening: isSettled ? 1 : 0.5, glow: Palette.glow)
                .frame(width: 120, height: 120)

            VStack(spacing: 6) {
                Text(title)
                    .font(.system(.title2, design: .rounded, weight: .semibold))

                Text(message)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .onAppear {
            withAnimation(Motion.reveal.delay(0.3)) {
                isSettled = true
            }
        }
    }
}

#Preview {
    EmptyStateView(title: "Nothing left to clear.", message: "Your library has room to breathe.")
}

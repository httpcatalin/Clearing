import SwiftUI

struct IntroView: View {
    let onFinished: () -> Void

    @State private var opening: CGFloat = 1.6
    @State private var isMarkVisible = false
    @State private var isNameVisible = false
    @State private var isLeaving = false
    @State private var hasOpened = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Palette.canvas
                .ignoresSafeArea()
                .opacity(isLeaving ? 0 : 1)

            VStack(spacing: 20) {
                SplitMark(opening: opening, glow: Palette.glow)
                    .frame(width: 112, height: 112)
                    .scaleEffect(markScale)
                    .opacity(isMarkVisible && !isLeaving ? 1 : 0)

                Text("Clearing")
                    .font(.system(.title2, design: .rounded, weight: .semibold))
                    .opacity(isNameVisible && !isLeaving ? 1 : 0)
                    .offset(y: isNameVisible ? 0 : 8)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onFinished)
        .sensoryFeedback(Haptics.open, trigger: hasOpened) { _, didOpen in
            didOpen
        }
        .accessibilityHidden(true)
        .task {
            await play()
        }
    }

    private var markScale: CGFloat {
        if isLeaving && !reduceMotion { return 3 }
        return isMarkVisible || reduceMotion ? 1 : 0.86
    }

    private func play() async {
        if reduceMotion {
            opening = 0.5
            withAnimation(.easeOut(duration: 0.35)) {
                isMarkVisible = true
                isNameVisible = true
            }
            await pause(1.0)
            leave(animation: .easeInOut(duration: 0.35))
            return
        }

        withAnimation(.spring(response: 0.7, dampingFraction: 0.82)) {
            isMarkVisible = true
            opening = 0
        }
        await pause(0.85)

        hasOpened = true
        withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) {
            opening = 0.5
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.12)) {
            isNameVisible = true
        }
        await pause(1.05)

        withAnimation(.easeIn(duration: 0.5)) {
            opening = 4
        }
        leave(animation: .easeIn(duration: 0.5))
    }

    private func leave(animation: Animation) {
        guard !Task.isCancelled else { return }
        withAnimation(animation) {
            isLeaving = true
        } completion: {
            onFinished()
        }
    }

    private func pause(_ seconds: Double) async {
        try? await Task.sleep(for: .seconds(seconds))
    }
}

#Preview {
    IntroView {}
}

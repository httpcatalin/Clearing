import SwiftUI

struct PrimaryButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                Spacer(minLength: 0)
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
                    .background(Palette.onAccent.opacity(0.16), in: Circle())
                    .accessibilityHidden(true)
            }
            .font(.headline)
            .foregroundStyle(Palette.onAccent)
            .padding(.leading, 24)
            .padding(.trailing, 10)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(Palette.accent, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct PressableButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .opacity(configuration.isPressed && reduceMotion ? 0.75 : 1)
            .animation(Motion.micro, value: configuration.isPressed)
    }
}

#Preview {
    PrimaryButton(title: "Start cleaning", systemImage: "arrow.right") {}
        .padding()
}

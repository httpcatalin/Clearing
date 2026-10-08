import SwiftUI

enum SplitPart {
    case lid
    case body
}

enum Split {
    static let angle = Angle.degrees(24)
    static let cut: CGFloat = 0.38
    static let gapRatio: CGFloat = 0.3
    static let shearRatio: CGFloat = 0.1

    static let direction = CGPoint(x: cos(angle.radians), y: -sin(angle.radians))
    static let normal = CGPoint(x: sin(angle.radians), y: cos(angle.radians))

    static func offset(for part: SplitPart, opening: CGFloat, in size: CGSize) -> CGSize {
        let unit = min(size.width, size.height)
        let gap = opening * gapRatio * unit / 2
        let shear = opening * shearRatio * unit
        let sign: CGFloat = part == .lid ? -1 : 1
        return CGSize(
            width: sign * (normal.x * gap - direction.x * shear),
            height: sign * (normal.y * gap - direction.y * shear)
        )
    }
}

struct SplitHalf: Shape {
    let part: SplitPart
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let side: CGFloat = part == .body ? 1 : -1
        let overlap: CGFloat = 0.75
        let length = (rect.width + rect.height) * 2
        let d = Split.direction
        let n = Split.normal
        let start = CGPoint(
            x: rect.midX - n.x * side * overlap,
            y: rect.minY + rect.height * Split.cut - n.y * side * overlap
        )

        var half = Path()
        half.move(to: CGPoint(x: start.x + d.x * length, y: start.y + d.y * length))
        half.addLine(to: CGPoint(x: start.x + d.x * length + n.x * side * length, y: start.y + d.y * length + n.y * side * length))
        half.addLine(to: CGPoint(x: start.x - d.x * length + n.x * side * length, y: start.y - d.y * length + n.y * side * length))
        half.addLine(to: CGPoint(x: start.x - d.x * length, y: start.y - d.y * length))
        half.closeSubpath()

        return Path(roundedRect: rect, cornerRadius: cornerRadius, style: .continuous).intersection(half)
    }
}

struct SplitView<Content: View>: View {
    var opening: CGFloat
    var cornerRadius: CGFloat
    var lidOpacity: Double = 1
    var glow: Color?
    @ViewBuilder var content: Content

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                if let glow {
                    glowBand(color: glow, size: size)
                }

                content
                    .frame(width: size.width, height: size.height)
                    .clipShape(SplitHalf(part: .body, cornerRadius: cornerRadius))
                    .offset(Split.offset(for: .body, opening: opening, in: size))

                content
                    .frame(width: size.width, height: size.height)
                    .clipShape(SplitHalf(part: .lid, cornerRadius: cornerRadius))
                    .offset(Split.offset(for: .lid, opening: opening, in: size))
                    .opacity(lidOpacity)
            }
            .compositingGroup()
        }
    }

    private func glowBand(color: Color, size: CGSize) -> some View {
        let gap = max(opening * Split.gapRatio * min(size.width, size.height), 0)

        return Rectangle()
            .fill(color)
            .frame(width: (size.width + size.height) * 1.5, height: gap)
            .rotationEffect(-Split.angle)
            .position(x: size.width / 2, y: size.height * Split.cut)
            .blur(radius: gap * 0.25)
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .opacity(Double(min(opening * 8, 1)))
    }
}

struct SplitMark: View {
    var opening: CGFloat = 0.5
    var color: Color = Palette.accent
    var glow: Color?

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)

            SplitView(opening: opening, cornerRadius: size * 0.82 * Radius.markRatio, lidOpacity: lidOpacity, glow: glow) {
                color
            }
            .padding(size * 0.09)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }

    private var lidOpacity: Double {
        1 - 0.55 * Double(min(max(opening, 0) / 0.5, 1))
    }
}

#Preview {
    HStack(spacing: 24) {
        SplitMark(opening: 0)
        SplitMark(opening: 0.5)
        SplitMark(opening: 1, glow: Palette.glow)
    }
    .frame(height: 90)
    .padding()
}

import SwiftUI

struct ScreenContainer<Content: View, BottomBar: View>: View {
    var background: Color = Palette.canvas
    @ViewBuilder let content: Content
    @ViewBuilder let bottomBar: BottomBar

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                content
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
                .padding(.horizontal, Spacing.screen)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(background)
        }
        .background(background.ignoresSafeArea())
    }
}

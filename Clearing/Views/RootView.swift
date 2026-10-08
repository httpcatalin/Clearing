import SwiftUI

struct RootView: View {
    let viewModel: PhotoReviewViewModel

    @State private var screen = Screen.home
    @State private var showsIntro = true

    var body: some View {
        ZStack {
            switch screen {
            case .home:
                HomeView(viewModel: viewModel, isActive: !showsIntro, onStart: startCleaning)
                    .transition(.opacity)
            case .review:
                ReviewView(viewModel: viewModel, onClose: returnHome)
                    .transition(.opacity)
            }

            if showsIntro {
                IntroView {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showsIntro = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .background(Palette.canvas.ignoresSafeArea())
    }

    private func startCleaning() {
        viewModel.startReview()
        withAnimation(Motion.navigation) {
            screen = .review
        }
    }

    private func returnHome() {
        withAnimation(Motion.navigation) {
            screen = .home
        }
    }

    private enum Screen {
        case home
        case review
    }
}

#Preview {
    RootView(
        viewModel: PhotoReviewViewModel(
            reviewService: PhotoReviewService(repository: LocalPhotoRepository())
        )
    )
}

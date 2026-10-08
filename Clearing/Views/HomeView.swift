import SwiftUI

struct HomeView: View {
    let viewModel: PhotoReviewViewModel
    let isActive: Bool
    let onStart: () -> Void

    @State private var isRevealed = false
    @State private var isLeaving = false
    @State private var touch: CGPoint?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScreenContainer {
            VStack(alignment: .leading, spacing: 0) {
                brandHeader

                if viewModel.hasPhotos {
                    libraryContent
                } else {
                    Spacer(minLength: 48)
                    EmptyStateView(title: "Nothing left to clear.", message: "Your library has room to breathe.")
                    Spacer(minLength: 48)
                }
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.top, 12)
            .padding(.bottom, 4)
        } bottomBar: {
            if viewModel.hasPhotos {
                PrimaryButton(title: "Start cleaning", systemImage: "arrow.right", action: start)
                    .opacity(isRevealed && !isLeaving ? 1 : 0)
                    .disabled(isLeaving)
            }
        }
        .sensoryFeedback(Haptics.touch, trigger: touch != nil) { _, isTouching in
            isTouching
        }
        .sensoryFeedback(Haptics.open, trigger: isLeaving) { _, isNowLeaving in
            isNowLeaving
        }
        .onAppear {
            if isActive {
                reveal()
            }
        }
        .onChange(of: isActive) { _, isNowActive in
            if isNowActive {
                reveal()
            }
        }
    }

    private var brandHeader: some View {
        HStack(spacing: 8) {
            SplitMark(opening: 0.5)
                .frame(width: 28, height: 28)

            Text("Clearing")
                .font(Typography.brand)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private var libraryContent: some View {
        Spacer(minLength: Spacing.section)

        slab
            .frame(maxWidth: 340)
            .frame(maxWidth: .infinity)

        Spacer(minLength: Spacing.section)

        VStack(alignment: .leading, spacing: 8) {
            Text("Make room.")
                .font(Typography.hero)

            Text(viewModel.librarySummaryText)
                .font(.body)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .opacity(isRevealed && !isLeaving ? 1 : 0)
        .offset(y: isRevealed || reduceMotion ? 0 : 12)
        .padding(.bottom, 8)
    }

    private var slab: some View {
        GeometryReader { proxy in
            LibrarySlab(photos: viewModel.mosaicPhotos, opening: slabOpening)
                .rotation3DEffect(.degrees(tilt.x * 7), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
                .rotation3DEffect(.degrees(-tilt.y * 7), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
                .scaleEffect(isLeaving && !reduceMotion ? 1.18 : 1)
                .opacity(isLeaving ? 0 : 1)
                .animation(Motion.gesture, value: touch == nil)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            touch = normalized(value.location, in: proxy.size)
                        }
                        .onEnded { _ in
                            withAnimation(Motion.gesture) {
                                touch = nil
                            }
                        }
                )
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var slabOpening: CGFloat {
        if isLeaving { return 2.6 }
        guard isRevealed else { return 0 }
        return touch == nil ? 0.16 : 0.38
    }

    private var tilt: CGPoint {
        guard let touch, !reduceMotion else { return .zero }
        return touch
    }

    private func normalized(_ location: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(
            x: min(max(location.x / size.width * 2 - 1, -1), 1),
            y: min(max(location.y / size.height * 2 - 1, -1), 1)
        )
    }

    private func reveal() {
        withAnimation(Motion.reveal.delay(reduceMotion ? 0 : 0.05)) {
            isRevealed = true
        }
    }

    private func start() {
        withAnimation(Motion.navigation) {
            isLeaving = true
        }
        Task {
            try? await Task.sleep(for: .milliseconds(reduceMotion ? 120 : 320))
            onStart()
        }
    }
}

private struct EmptyPhotoRepository: PhotoRepository {
    func getPhotos() -> [Photo] {
        []
    }
}

#Preview("Library") {
    HomeView(
        viewModel: PhotoReviewViewModel(
            reviewService: PhotoReviewService(repository: LocalPhotoRepository())
        ),
        isActive: true,
        onStart: {}
    )
}

#Preview("Empty") {
    HomeView(
        viewModel: PhotoReviewViewModel(
            reviewService: PhotoReviewService(repository: EmptyPhotoRepository())
        ),
        isActive: true,
        onStart: {}
    )
}

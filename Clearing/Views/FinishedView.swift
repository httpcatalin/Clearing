import SwiftUI

struct FinishedView: View {
    let viewModel: PhotoReviewViewModel
    let onDone: () -> Void

    @State private var isOpen = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScreenContainer(background: .clear) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: Spacing.screen)

                LibrarySlab(
                    photos: viewModel.mosaicPhotos,
                    opening: isOpen ? 0.16 : 0,
                    clearedPhotoIDs: viewModel.removedPhotoIDs,
                    showsCleared: isOpen,
                    breathes: isOpen
                )
                .frame(maxWidth: 300)
                .frame(maxWidth: .infinity)
                .scaleEffect(isOpen || reduceMotion ? 1 : 0.94)

                Spacer(minLength: Spacing.section)

                VStack(alignment: .leading, spacing: 0) {
                    Text(viewModel.finishedTitle)
                        .font(Typography.display)

                    Text(viewModel.reviewedText)
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)

                    StatRow {
                        StatView(value: "\(viewModel.keptCount)", label: "kept")
                        StatView(value: "\(viewModel.deletedCount)", label: "cleared")
                        StatView(value: viewModel.spaceToFreeText, label: "to free up")
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 12)
                }
                .modifier(RevealOnOpen(isOpen: isOpen, reduceMotion: reduceMotion))
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.top, 12)
            .padding(.bottom, 4)
        } bottomBar: {
            PrimaryButton(title: "Done", systemImage: "checkmark", action: onDone)
                .modifier(RevealOnOpen(isOpen: isOpen, reduceMotion: reduceMotion))
        }
        .haptic(Haptics.complete, trigger: isOpen) { _, isNowOpen in
            isNowOpen
        }
        .task {
            guard !reduceMotion else {
                isOpen = true
                return
            }
            try? await Task.sleep(for: .milliseconds(500))
            withAnimation(Motion.completion) {
                isOpen = true
            }
        }
    }
}

private struct RevealOnOpen: ViewModifier {
    let isOpen: Bool
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isOpen ? 1 : 0)
            .offset(y: isOpen || reduceMotion ? 0 : 16)
            .animation(reduceMotion ? nil : Motion.reveal.delay(0.35), value: isOpen)
    }
}

private func previewViewModel() -> PhotoReviewViewModel {
    let viewModel = PhotoReviewViewModel(
        reviewService: PhotoReviewService(repository: LocalPhotoRepository()),
        keepActionFactory: KeepPhotoActionFactory(),
        deleteActionFactory: DeletePhotoActionFactory()
    )
    for index in 0..<viewModel.totalCount {
        if index % 3 == 1 {
            viewModel.deleteCurrentPhoto()
        } else {
            viewModel.keepCurrentPhoto()
        }
    }
    return viewModel
}

#Preview {
    FinishedView(viewModel: previewViewModel(), onDone: {})
}

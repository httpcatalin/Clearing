import SwiftUI

struct ReviewView: View {
    let viewModel: PhotoReviewViewModel
    let onFinished: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var isSwipingOut = false

    private let swipeThreshold: CGFloat = 120
    private let swipeOutDistance: CGFloat = 600

    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: viewModel.progress)
                .animation(.easeOut(duration: 0.3), value: viewModel.progress)

            photoStack

            photoDetails

            actionButtons
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.reviewedCount)
    }

    private var photoStack: some View {
        ZStack {
            ForEach(viewModel.upcomingPhotos.reversed()) { photo in
                let isTopCard = photo == viewModel.currentPhoto

                PhotoCard(photo: photo)
                    .overlay {
                        if isTopCard {
                            decisionBadge
                        }
                    }
                    .offset(isTopCard ? dragOffset : .zero)
                    .rotationEffect(.degrees(isTopCard ? dragOffset.width / 18 : 0), anchor: .bottom)
                    .allowsHitTesting(isTopCard)
                    .gesture(dragGesture)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var decisionBadge: some View {
        let isKeep = dragOffset.width > 0

        return Label(isKeep ? "Keep" : "Delete", systemImage: isKeep ? "checkmark" : "trash")
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isKeep ? Color.accentColor : Color.red, in: Capsule())
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: isKeep ? .topLeading : .topTrailing)
            .opacity(min(abs(dragOffset.width) / swipeThreshold, 1))
    }

    private var photoDetails: some View {
        VStack(spacing: 4) {
            Text(viewModel.positionText)
                .font(.headline)
                .contentTransition(.numericText())

            Text(viewModel.currentSizeText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .monospacedDigit()
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: delete) {
                Label("Delete", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)

            Button(action: keep) {
                Label("Keep", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .font(.headline)
        .controlSize(.large)
        .buttonBorderShape(.capsule)
        .disabled(isSwipingOut || viewModel.isFinished)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard !isSwipingOut else { return }
                dragOffset = value.translation
            }
            .onEnded { value in
                guard !isSwipingOut else { return }
                let predictedWidth = value.predictedEndTranslation.width

                if predictedWidth > swipeThreshold {
                    keep()
                } else if predictedWidth < -swipeThreshold {
                    delete()
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    private func keep() {
        swipeOut(toRight: true, then: viewModel.keepCurrentPhoto)
    }

    private func delete() {
        swipeOut(toRight: false, then: viewModel.deleteCurrentPhoto)
    }

    private func swipeOut(toRight: Bool, then decide: @escaping () -> Void) {
        guard !isSwipingOut else { return }
        isSwipingOut = true

        withAnimation(.easeIn(duration: 0.22)) {
            dragOffset = CGSize(width: toRight ? swipeOutDistance : -swipeOutDistance, height: dragOffset.height)
        } completion: {
            decide()
            dragOffset = .zero
            isSwipingOut = false

            if viewModel.isFinished {
                onFinished()
            }
        }
    }
}

private struct PhotoCard: View {
    let photo: Photo

    var body: some View {
        Color.clear
            .aspectRatio(3 / 4, contentMode: .fit)
            .overlay {
                Image(photo.imageName)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
            .accessibilityElement()
            .accessibilityLabel("Photo")
            .accessibilityHint("Swipe right to keep, swipe left to delete")
    }
}

#Preview {
    NavigationStack {
        ReviewView(
            viewModel: PhotoReviewViewModel(
                reviewService: PhotoReviewService(repository: LocalPhotoRepository())
            ),
            onFinished: {}
        )
    }
}

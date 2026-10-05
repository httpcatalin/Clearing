import SwiftUI

struct HomeView: View {
    let viewModel: PhotoReviewViewModel

    @State private var isReviewing = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                header

                Spacer(minLength: 24)

                PhotoStackPreview(photos: viewModel.previewPhotos)
                    .frame(maxWidth: .infinity)

                Spacer(minLength: 24)

                summary
                    .padding(.bottom, 20)

                startButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 16)
            .navigationDestination(isPresented: $isReviewing) {
                ReviewView(viewModel: viewModel) {
                    isReviewing = false
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("CleanSpace")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .tracking(-0.5)

            Text("A simpler way to clean your photos.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var summary: some View {
        VStack(spacing: 4) {
            Text(viewModel.summaryText)
                .font(.headline)

            Text(viewModel.totalSizeText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var startButton: some View {
        Button {
            viewModel.startReview()
            isReviewing = true
        } label: {
            Text("Start Cleaning")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .disabled(!viewModel.hasPhotos)
    }
}

private struct PhotoStackPreview: View {
    let photos: [Photo]

    var body: some View {
        ZStack {
            ForEach(Array(photos.enumerated().reversed()), id: \.element.id) { index, photo in
                Image(photo.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 190, height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
                    .rotationEffect(.degrees(rotation(for: index)), anchor: .bottom)
                    .offset(x: offset(for: index))
            }
        }
        .accessibilityHidden(true)
    }

    private func rotation(for index: Int) -> Double {
        [0, -8, 8][index % 3]
    }

    private func offset(for index: Int) -> CGFloat {
        [0, -34, 34][index % 3]
    }
}

#Preview {
    HomeView(
        viewModel: PhotoReviewViewModel(
            reviewService: PhotoReviewService(repository: LocalPhotoRepository())
        )
    )
}

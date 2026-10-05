import SwiftUI

struct FinishedView: View {
    let viewModel: PhotoReviewViewModel
    let onStartAgain: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text("You're done!")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .padding(.top, 20)

            Text(viewModel.reviewedText)
                .font(.title3)
                .foregroundStyle(.secondary)
                .padding(.top, 6)

            results
                .padding(.top, 36)

            Spacer()

            Button(action: onStartAgain) {
                Text("Start Again")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .navigationBarBackButtonHidden()
    }

    private var results: some View {
        HStack(spacing: 0) {
            ResultItem(value: "\(viewModel.keptCount)", title: "Kept")
            Divider().frame(height: 40)
            ResultItem(value: "\(viewModel.deletedCount)", title: "To delete")
            Divider().frame(height: 40)
            ResultItem(value: viewModel.spaceToFreeText, title: "To free up")
        }
    }
}

private struct ResultItem: View {
    let value: String
    let title: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.semibold))
                .monospacedDigit()

            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FinishedView(
        viewModel: PhotoReviewViewModel(
            reviewService: PhotoReviewService(repository: LocalPhotoRepository())
        ),
        onStartAgain: {}
    )
}

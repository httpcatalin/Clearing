import SwiftUI

@main
struct CleanSpaceApp: App {
    // DIP: this is the only place that chooses the concrete repository.
    // Replacing LocalPhotoRepository with a PhotoKit repository changes only this line.
    @State private var viewModel = PhotoReviewViewModel(
        reviewService: PhotoReviewService(repository: LocalPhotoRepository())
    )

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: viewModel)
        }
    }
}

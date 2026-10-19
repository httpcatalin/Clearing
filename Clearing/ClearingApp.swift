import SwiftUI

@main
struct ClearingApp: App {
    @State private var viewModel = PhotoReviewViewModel(
        reviewService: PhotoReviewService(repository: LocalPhotoRepository()),
        keepActionFactory: KeepPhotoActionFactory(),
        deleteActionFactory: DeletePhotoActionFactory()
    )

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: viewModel)
        }
    }
}

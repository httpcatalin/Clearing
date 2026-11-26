import SwiftUI

@main
struct ClearingApp: App {
    @State private var viewModel = PhotoReviewViewModel(
        facade: PhotoReviewFacade(
            libraryRepository: LocalPhotoRepository(),
            archiveRepository: LegacyPhotoRepositoryAdapter(provider: LegacyPhotoProvider()),
            keepActionFactory: KeepPhotoActionFactory(),
            deleteActionFactory: DeletePhotoActionFactory()
        )
    )

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: viewModel)
        }
    }
}

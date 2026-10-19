import Testing
@testable import Clearing

private struct EmptyPhotoRepository: PhotoRepository {
    func getPhotos() -> [Photo] {
        []
    }
}

private func makeViewModel(repository: PhotoRepository = LocalPhotoRepository()) -> PhotoReviewViewModel {
    PhotoReviewViewModel(
        reviewService: PhotoReviewService(repository: repository),
        keepActionFactory: KeepPhotoActionFactory(),
        deleteActionFactory: DeletePhotoActionFactory()
    )
}

@Suite(.serialized)
struct SingletonTests {
    @Test func sharedAlwaysReturnsTheSameInstance() {
        #expect(ClearingSettings.shared === ClearingSettings.shared)
    }

    @Test func aChangeIsVisibleEverywhere() {
        let settings = ClearingSettings.shared
        let original = settings.hapticsEnabled
        defer { settings.hapticsEnabled = original }

        settings.hapticsEnabled = false

        #expect(ClearingSettings.shared.hapticsEnabled == false)
    }

    @Test func reviewModeFromSettingsReachesTheReview() {
        let settings = ClearingSettings.shared
        let original = settings.reviewMode
        defer { settings.reviewMode = original }

        settings.reviewMode = .compact
        let viewModel = makeViewModel()
        viewModel.startReview()

        #expect(viewModel.reviewMode == .compact)
    }
}

struct FactoryMethodTests {
    @Test func keepFactoryCreatesAKeepAction() {
        #expect(KeepPhotoActionFactory().makeAction() is KeepPhotoAction)
    }

    @Test func deleteFactoryCreatesADeleteAction() {
        #expect(DeletePhotoActionFactory().makeAction() is DeletePhotoAction)
    }

    @Test func everyCallCreatesANewAction() {
        let factory = KeepPhotoActionFactory()
        let first = factory.makeAction() as AnyObject
        let second = factory.makeAction() as AnyObject

        #expect(first !== second)
    }
}

struct BuilderTests {
    private let photos = LocalPhotoRepository().getPhotos()

    @Test func buildsASessionWithTheGivenValues() {
        let session = ReviewSessionBuilder()
            .setPhotos(photos)
            .setStartingIndex(3)
            .setReviewMode(.compact)
            .build()

        #expect(session.photos == photos)
        #expect(session.startIndex == 3)
        #expect(session.mode == .compact)
    }

    @Test func usesSensibleDefaults() {
        let session = ReviewSessionBuilder().build()

        #expect(session.photos.isEmpty)
        #expect(session.startIndex == 0)
        #expect(session.mode == .detailed)
    }

    @Test func fixesAStartingIndexThatIsTooBig() {
        let session = ReviewSessionBuilder()
            .setPhotos(photos)
            .setStartingIndex(50)
            .build()

        #expect(session.startIndex == photos.count - 1)
    }

    @Test func fixesANegativeStartingIndex() {
        let session = ReviewSessionBuilder()
            .setPhotos(photos)
            .setStartingIndex(-3)
            .build()

        #expect(session.startIndex == 0)
    }

    @Test func emptyPhotosGiveASafeSession() {
        let session = ReviewSessionBuilder()
            .setPhotos([])
            .setStartingIndex(7)
            .build()

        #expect(session.photos.isEmpty)
        #expect(session.startIndex == 0)
    }

    @Test func serviceStartsFromTheSessionIndex() {
        let session = ReviewSessionBuilder()
            .setPhotos(photos)
            .setStartingIndex(4)
            .build()
        let service = PhotoReviewService(repository: LocalPhotoRepository())

        service.start(session)

        #expect(service.currentPhoto == photos[4])
    }
}

struct ReviewFlowTests {
    @Test func keepAndClearStillWork() {
        let viewModel = makeViewModel()
        viewModel.startReview()

        viewModel.keepCurrentPhoto()
        viewModel.deleteCurrentPhoto()

        #expect(viewModel.reviewedCount == 2)
        #expect(viewModel.keptCount == 1)
        #expect(viewModel.deletedCount == 1)
        #expect(viewModel.spaceToFree > 0)
    }

    @Test func reviewEndsAfterTheLastPhoto() {
        let viewModel = makeViewModel()
        viewModel.startReview()

        for _ in 0..<viewModel.totalCount {
            viewModel.keepCurrentPhoto()
        }

        #expect(viewModel.isFinished)
        #expect(viewModel.keptCount == viewModel.totalCount)
    }

    @Test func emptyLibraryIsSafe() {
        let viewModel = makeViewModel(repository: EmptyPhotoRepository())
        viewModel.startReview()
        viewModel.keepCurrentPhoto()

        #expect(viewModel.hasPhotos == false)
        #expect(viewModel.isFinished)
        #expect(viewModel.keptCount == 0)
    }

    @Test func startingAgainResetsTheResults() {
        let viewModel = makeViewModel()
        viewModel.startReview()
        viewModel.deleteCurrentPhoto()

        viewModel.startReview()

        #expect(viewModel.reviewedCount == 0)
        #expect(viewModel.deletedCount == 0)
    }
}

import Testing
import UIKit
@testable import Clearing

private final class CountingAction: PhotoAction {
    private(set) var executeCount = 0
    private(set) var undoCount = 0
    private(set) var handledPhotos: [Photo] = []

    func execute(on photo: Photo) {
        executeCount += 1
        handledPhotos.append(photo)
    }

    func undo(on photo: Photo) {
        undoCount += 1
        handledPhotos.removeAll { $0.id == photo.id }
    }
}

private func makeFacade() -> PhotoReviewFacade {
    PhotoReviewFacade(
        libraryRepository: LocalPhotoRepository(),
        archiveRepository: LegacyPhotoRepositoryAdapter(provider: LegacyPhotoProvider()),
        keepActionFactory: KeepPhotoActionFactory(),
        deleteActionFactory: DeletePhotoActionFactory()
    )
}

struct AdapterTests {
    @Test func convertsLegacyPhotosIntoPhotos() {
        let legacyPhotos = LegacyPhotoProvider().fetchArchivedPhotos()
        let photos = LegacyPhotoRepositoryAdapter(provider: LegacyPhotoProvider()).getPhotos()

        #expect(photos.count == legacyPhotos.count)
        #expect(photos[0].imageName == "sample-09")
        #expect(photos[0].sizeInBytes == 6_100_000)
    }

    @Test func everyConvertedPhotoHasAnImageInTheApp() {
        let photos = LegacyPhotoRepositoryAdapter(provider: LegacyPhotoProvider()).getPhotos()

        for photo in photos {
            #expect(UIImage(named: photo.imageName) != nil)
        }
    }

    @Test func worksThroughTheRepositoryProtocol() {
        let repository: PhotoRepository = LegacyPhotoRepositoryAdapter(provider: LegacyPhotoProvider())
        let service = PhotoReviewService(repository: repository)

        #expect(service.photos.count == 8)
        #expect(service.currentPhoto?.imageName == "sample-09")
    }
}

struct FacadeTests {
    @Test func startsAReviewWithTheExistingSubsystem() {
        let facade = makeFacade()

        facade.startReview(mode: .compact)

        #expect(facade.canDecide)
        #expect(facade.photos.count == 12)
        #expect(facade.currentPhoto == facade.photos.first)
        #expect(facade.reviewMode == .compact)
        #expect(facade.reviewedCount == 0)
    }

    @Test func keepAndClearGoThroughTheSubsystem() {
        let facade = makeFacade()
        facade.startReview(mode: .detailed)
        let secondPhoto = facade.photos[1]

        facade.keepCurrentPhoto()
        facade.deleteCurrentPhoto()

        #expect(facade.keptCount == 1)
        #expect(facade.deletedCount == 1)
        #expect(facade.reviewedCount == 2)
        #expect(facade.spaceToFree == secondPhoto.sizeInBytes)
        #expect(facade.removedPhotoIDs == [secondPhoto.id])
        #expect(facade.canUndo)
    }

    @Test func undoGoesBackOnePhoto() {
        let facade = makeFacade()
        facade.startReview(mode: .detailed)
        let firstPhoto = facade.photos[0]

        facade.deleteCurrentPhoto()
        facade.undoLastDecision()

        #expect(facade.deletedCount == 0)
        #expect(facade.spaceToFree == 0)
        #expect(facade.reviewedCount == 0)
        #expect(facade.currentPhoto == firstPhoto)
        #expect(facade.removedPhotoIDs.isEmpty)
        #expect(facade.canUndo == false)
    }

    @Test func pauseBlocksDecisionsAndResumeAllowsThem() {
        let facade = makeFacade()
        facade.startReview(mode: .detailed)

        facade.pauseReview()
        facade.keepCurrentPhoto()

        #expect(facade.isPaused)
        #expect(facade.canDecide == false)
        #expect(facade.keptCount == 0)

        facade.resumeReview()
        facade.keepCurrentPhoto()

        #expect(facade.isPaused == false)
        #expect(facade.keptCount == 1)
    }

    @Test func finishesAfterTheLastPhoto() {
        let facade = makeFacade()
        facade.startReview(mode: .detailed)

        for _ in facade.photos {
            facade.keepCurrentPhoto()
        }

        #expect(facade.isFinished)
        #expect(facade.canDecide == false)
        #expect(facade.keptCount == 12)
    }

    @Test func selectingTheArchiveUsesTheAdapter() {
        let facade = makeFacade()

        facade.selectSource(.archive)
        facade.startReview(mode: .detailed)

        #expect(facade.photos.count == 8)
        #expect(facade.currentPhoto?.imageName == "sample-09")

        facade.selectSource(.library)

        #expect(facade.photos.count == 12)
    }

    @Test func changingTheSourceEndsARunningReview() {
        let facade = makeFacade()
        facade.startReview(mode: .detailed)
        facade.keepCurrentPhoto()

        facade.selectSource(.archive)
        facade.keepCurrentPhoto()

        #expect(facade.canDecide == false)
        #expect(facade.currentPhoto?.imageName == "sample-09")
    }
}

@Suite(.serialized)
struct DecoratorTests {
    private let photo = Photo(imageName: "sample-01", sizeInBytes: 4_200_000)

    @Test func wrappedActionRunsExactlyOnce() {
        let action = CountingAction()
        let decorated = HapticPhotoActionDecorator(
            wrapping: LoggingPhotoActionDecorator(wrapping: action, name: "Keep") { _ in },
            playFeedback: {}
        )

        decorated.execute(on: photo)
        decorated.undo(on: photo)

        #expect(action.executeCount == 1)
        #expect(action.undoCount == 1)
    }

    @Test func loggingWritesWhatHappened() {
        var messages: [String] = []
        let decorated = LoggingPhotoActionDecorator(wrapping: CountingAction(), name: "Keep") { message in
            messages.append(message)
        }

        decorated.execute(on: photo)
        decorated.undo(on: photo)

        #expect(messages == ["Keep sample-01", "Undo Keep sample-01"])
    }

    @Test func hapticPlaysWhenHapticsAreOn() {
        let settings = ClearingSettings.shared
        let original = settings.hapticsEnabled
        defer { settings.hapticsEnabled = original }
        settings.hapticsEnabled = true
        var playCount = 0
        let decorated = HapticPhotoActionDecorator(wrapping: CountingAction()) {
            playCount += 1
        }

        decorated.execute(on: photo)

        #expect(playCount == 1)
    }

    @Test func hapticStaysSilentWhenHapticsAreOff() {
        let settings = ClearingSettings.shared
        let original = settings.hapticsEnabled
        defer { settings.hapticsEnabled = original }
        settings.hapticsEnabled = false
        var playCount = 0
        let action = CountingAction()
        let decorated = HapticPhotoActionDecorator(wrapping: action) {
            playCount += 1
        }

        decorated.execute(on: photo)

        #expect(playCount == 0)
        #expect(action.executeCount == 1)
    }

    @Test func decoratorsCanBeCombinedInAnyOrder() {
        let settings = ClearingSettings.shared
        let original = settings.hapticsEnabled
        defer { settings.hapticsEnabled = original }
        settings.hapticsEnabled = true
        var messages: [String] = []
        var playCount = 0
        let keepAction = KeepPhotoAction()
        let decorated = LoggingPhotoActionDecorator(
            wrapping: HapticPhotoActionDecorator(wrapping: keepAction) { playCount += 1 },
            name: "Keep"
        ) { message in
            messages.append(message)
        }

        decorated.execute(on: photo)

        #expect(decorated.handledPhotos == [photo])
        #expect(keepAction.keptPhotos == [photo])
        #expect(messages == ["Keep sample-01"])
        #expect(playCount == 1)
    }
}

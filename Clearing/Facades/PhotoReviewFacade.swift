import Foundation

final class PhotoReviewFacade {
    private let libraryRepository: PhotoRepository
    private let archiveRepository: PhotoRepository
    private let keepActionFactory: PhotoActionFactory
    private let deleteActionFactory: PhotoActionFactory
    private let reviewService: PhotoReviewService
    private let subject = ReviewSessionSubject()
    private let progressObserver = ReviewProgressObserver()
    private let statisticsObserver = ReviewStatisticsObserver()
    private let session: ReviewSessionContext
    private var keepAction: PhotoAction
    private var deleteAction: PhotoAction

    init(
        libraryRepository: PhotoRepository,
        archiveRepository: PhotoRepository,
        keepActionFactory: PhotoActionFactory,
        deleteActionFactory: PhotoActionFactory
    ) {
        self.libraryRepository = libraryRepository
        self.archiveRepository = archiveRepository
        self.keepActionFactory = keepActionFactory
        self.deleteActionFactory = deleteActionFactory
        reviewService = PhotoReviewService(repository: libraryRepository)
        session = ReviewSessionContext(reviewService: reviewService, subject: subject)
        keepAction = keepActionFactory.makeAction()
        deleteAction = deleteActionFactory.makeAction()
        subject.attach(progressObserver)
        subject.attach(statisticsObserver)
    }

    var photos: [Photo] {
        reviewService.photos
    }

    var currentPhoto: Photo? {
        reviewService.currentPhoto
    }

    var reviewMode: ReviewMode {
        reviewService.mode
    }

    var isPaused: Bool {
        session.isPaused
    }

    var canDecide: Bool {
        session.canDecide
    }

    var canUndo: Bool {
        session.canUndo
    }

    var reviewedCount: Int {
        progressObserver.reviewedCount
    }

    var progress: Double {
        progressObserver.progress
    }

    var isFinished: Bool {
        progressObserver.isComplete
    }

    var keptCount: Int {
        statisticsObserver.keptCount
    }

    var deletedCount: Int {
        statisticsObserver.deletedCount
    }

    var spaceToFree: Int64 {
        statisticsObserver.spaceToFree
    }

    var removedPhotoIDs: Set<Photo.ID> {
        Set(deleteAction.handledPhotos.map(\.id))
    }

    func selectSource(_ source: PhotoSource) {
        session.close()
        reviewService.changeRepository(to: repository(for: source))
    }

    func startReview(mode: ReviewMode) {
        session.close()
        session.start(mode: mode)
        keepAction = keepActionFactory.makeAction()
        deleteAction = deleteActionFactory.makeAction()
    }

    func keepCurrentPhoto() {
        guard let photo = reviewService.currentPhoto else { return }
        let action = decorate(keepAction, name: "Keep", playFeedback: Haptics.playKeep)
        session.perform(KeepPhotoCommand(photo: photo, action: action, reviewService: reviewService, subject: subject))
    }

    func deleteCurrentPhoto() {
        guard let photo = reviewService.currentPhoto else { return }
        let action = decorate(deleteAction, name: "Clear", playFeedback: Haptics.playClear)
        session.perform(DeletePhotoCommand(photo: photo, action: action, reviewService: reviewService, subject: subject))
    }

    func undoLastDecision() {
        session.undo()
    }

    func pauseReview() {
        session.pause()
    }

    func resumeReview() {
        session.resume()
    }

    func closeReview() {
        session.close()
    }

    private func repository(for source: PhotoSource) -> PhotoRepository {
        switch source {
        case .library:
            libraryRepository
        case .archive:
            archiveRepository
        }
    }

    private func decorate(_ action: PhotoAction, name: String, playFeedback: @escaping () -> Void) -> PhotoAction {
        let loggedAction = LoggingPhotoActionDecorator(wrapping: action, name: name) { message in
            print(message)
        }
        return HapticPhotoActionDecorator(wrapping: loggedAction, playFeedback: playFeedback)
    }
}

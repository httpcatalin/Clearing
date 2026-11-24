import Foundation
import Observation

@Observable
final class PhotoReviewViewModel {
    private(set) var photos: [Photo] = []
    private(set) var currentPhoto: Photo?
    private(set) var reviewedCount = 0
    private(set) var progress: Double = 0
    private(set) var isFinished = false
    private(set) var isPaused = false
    private(set) var canDecide = false
    private(set) var canUndo = false
    private(set) var keptCount = 0
    private(set) var deletedCount = 0
    private(set) var spaceToFree: Int64 = 0
    private(set) var removedPhotoIDs: Set<Photo.ID> = []
    private(set) var reviewMode: ReviewMode = .detailed

    private let reviewService: PhotoReviewService
    private let keepActionFactory: PhotoActionFactory
    private let deleteActionFactory: PhotoActionFactory
    private var keepAction: PhotoAction
    private var deleteAction: PhotoAction
    private let subject = ReviewSessionSubject()
    private let progressObserver = ReviewProgressObserver()
    private let statisticsObserver = ReviewStatisticsObserver()
    private let session: ReviewSessionContext

    init(
        reviewService: PhotoReviewService,
        keepActionFactory: PhotoActionFactory,
        deleteActionFactory: PhotoActionFactory
    ) {
        self.reviewService = reviewService
        self.keepActionFactory = keepActionFactory
        self.deleteActionFactory = deleteActionFactory
        keepAction = keepActionFactory.makeAction()
        deleteAction = deleteActionFactory.makeAction()
        session = ReviewSessionContext(reviewService: reviewService, subject: subject)
        subject.attach(progressObserver)
        subject.attach(statisticsObserver)
        refresh()
    }

    var totalCount: Int {
        photos.count
    }

    var hasPhotos: Bool {
        !photos.isEmpty
    }

    var upcomingPhotos: [Photo] {
        Array(photos.dropFirst(reviewedCount).prefix(3))
    }

    var mosaicPhotos: [Photo] {
        Array(photos.prefix(12))
    }

    var librarySummaryText: String {
        "\(photoCountText(totalCount)) to review · \(totalSizeText)"
    }

    var totalSizeText: String {
        formattedSize(photos.reduce(0) { $0 + $1.sizeInBytes })
    }

    var positionText: String {
        "\(currentPosition) / \(totalCount)"
    }

    var positionAccessibilityText: String {
        "Photo \(currentPosition) of \(totalCount)"
    }

    var currentSizeText: String {
        formattedSize(currentPhoto?.sizeInBytes ?? 0)
    }

    var finishedTitle: String {
        deletedCount > 0 ? "More room." : "Everything stays."
    }

    var reviewedText: String {
        "\(photoCountText(reviewedCount)) reviewed"
    }

    var spaceToFreeText: String {
        formattedSize(spaceToFree)
    }

    func startReview() {
        session.close()
        session.start(mode: ClearingSettings.shared.reviewMode)
        keepAction = keepActionFactory.makeAction()
        deleteAction = deleteActionFactory.makeAction()
        refresh()
    }

    func keepCurrentPhoto() {
        guard let currentPhoto else { return }
        session.perform(KeepPhotoCommand(photo: currentPhoto, action: keepAction, reviewService: reviewService, subject: subject))
        refresh()
    }

    func deleteCurrentPhoto() {
        guard let currentPhoto else { return }
        session.perform(DeletePhotoCommand(photo: currentPhoto, action: deleteAction, reviewService: reviewService, subject: subject))
        refresh()
    }

    func undoLastDecision() {
        session.undo()
        refresh()
    }

    func pauseReview() {
        session.pause()
        refresh()
    }

    func resumeReview() {
        session.resume()
        refresh()
    }

    func closeReview() {
        session.close()
        refresh()
    }

    private func refresh() {
        photos = reviewService.photos
        currentPhoto = reviewService.currentPhoto
        reviewMode = reviewService.mode
        isPaused = session.isPaused
        canDecide = session.canDecide
        canUndo = session.canUndo
        reviewedCount = progressObserver.reviewedCount
        progress = progressObserver.progress
        isFinished = progressObserver.isComplete
        keptCount = statisticsObserver.keptCount
        deletedCount = statisticsObserver.deletedCount
        spaceToFree = statisticsObserver.spaceToFree
        removedPhotoIDs = Set(deleteAction.handledPhotos.map(\.id))
    }

    private var currentPosition: Int {
        min(reviewedCount + 1, totalCount)
    }

    private func photoCountText(_ count: Int) -> String {
        count == 1 ? "1 photo" : "\(count) photos"
    }

    private func formattedSize(_ bytes: Int64) -> String {
        Measurement(value: Double(bytes), unit: UnitInformationStorage.bytes)
            .converted(to: .megabytes)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0...1))))
    }
}

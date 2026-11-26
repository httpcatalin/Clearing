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

    private let facade: PhotoReviewFacade

    init(facade: PhotoReviewFacade) {
        self.facade = facade
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

    func selectSource(_ source: PhotoSource) {
        facade.selectSource(source)
        refresh()
    }

    func startReview() {
        facade.startReview(mode: ClearingSettings.shared.reviewMode)
        refresh()
    }

    func keepCurrentPhoto() {
        facade.keepCurrentPhoto()
        refresh()
    }

    func deleteCurrentPhoto() {
        facade.deleteCurrentPhoto()
        refresh()
    }

    func undoLastDecision() {
        facade.undoLastDecision()
        refresh()
    }

    func pauseReview() {
        facade.pauseReview()
        refresh()
    }

    func resumeReview() {
        facade.resumeReview()
        refresh()
    }

    func closeReview() {
        facade.closeReview()
        refresh()
    }

    private func refresh() {
        photos = facade.photos
        currentPhoto = facade.currentPhoto
        reviewMode = facade.reviewMode
        isPaused = facade.isPaused
        canDecide = facade.canDecide
        canUndo = facade.canUndo
        reviewedCount = facade.reviewedCount
        progress = facade.progress
        isFinished = facade.isFinished
        keptCount = facade.keptCount
        deletedCount = facade.deletedCount
        spaceToFree = facade.spaceToFree
        removedPhotoIDs = facade.removedPhotoIDs
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

import Foundation
import Observation

@Observable
final class PhotoReviewViewModel {
    private(set) var photos: [Photo] = []
    private(set) var currentPhoto: Photo?
    private(set) var reviewedCount = 0
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
        refresh()
    }

    var totalCount: Int {
        photos.count
    }

    var hasPhotos: Bool {
        !photos.isEmpty
    }

    var isFinished: Bool {
        currentPhoto == nil
    }

    var upcomingPhotos: [Photo] {
        Array(photos.dropFirst(reviewedCount).prefix(3))
    }

    var mosaicPhotos: [Photo] {
        Array(photos.prefix(12))
    }

    var progress: Double {
        hasPhotos ? Double(reviewedCount) / Double(totalCount) : 0
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
        reviewService.startReview(mode: ClearingSettings.shared.reviewMode)
        keepAction = keepActionFactory.makeAction()
        deleteAction = deleteActionFactory.makeAction()
        refresh()
    }

    func keepCurrentPhoto() {
        apply(keepAction)
    }

    func deleteCurrentPhoto() {
        apply(deleteAction)
    }

    private func apply(_ action: PhotoAction) {
        reviewService.apply(action)
        refresh()
    }

    private func refresh() {
        photos = reviewService.photos
        currentPhoto = reviewService.currentPhoto
        reviewedCount = reviewService.reviewedCount
        reviewMode = reviewService.mode
        keptCount = keepAction.handledPhotos.count
        deletedCount = deleteAction.handledPhotos.count
        spaceToFree = deleteAction.handledPhotos.reduce(0) { total, photo in total + photo.sizeInBytes }
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

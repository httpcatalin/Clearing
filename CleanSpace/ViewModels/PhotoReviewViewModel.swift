import Foundation
import Observation

// SRP: the view model prepares data for the screens (texts, counts, sizes)
// and forwards user taps to the review service.
@Observable
final class PhotoReviewViewModel {
    private(set) var photos: [Photo] = []
    private(set) var currentPhoto: Photo?
    private(set) var nextPhoto: Photo?
    private(set) var reviewedCount = 0
    private(set) var keptCount = 0
    private(set) var deletedCount = 0
    private(set) var spaceToFree: Int64 = 0

    private let reviewService: PhotoReviewService
    private var keepAction = KeepPhotoAction()
    private var deleteAction = DeletePhotoAction()

    init(reviewService: PhotoReviewService) {
        self.reviewService = reviewService
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
        [currentPhoto, nextPhoto].compactMap { $0 }
    }

    var previewPhotos: [Photo] {
        Array(photos.prefix(3))
    }

    var progress: Double {
        hasPhotos ? Double(reviewedCount) / Double(totalCount) : 0
    }

    var summaryText: String {
        "\(photoCountText(totalCount)) ready to review"
    }

    var totalSizeText: String {
        "\(formattedSize(photos.reduce(0) { $0 + $1.sizeInBytes })) in total"
    }

    var positionText: String {
        "Photo \(min(reviewedCount + 1, totalCount)) of \(totalCount)"
    }

    var currentSizeText: String {
        formattedSize(currentPhoto?.sizeInBytes ?? 0)
    }

    var reviewedText: String {
        "You reviewed \(photoCountText(reviewedCount))."
    }

    var spaceToFreeText: String {
        formattedSize(spaceToFree)
    }

    func startReview() {
        reviewService.startReview()
        keepAction = KeepPhotoAction()
        deleteAction = DeletePhotoAction()
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
        nextPhoto = reviewService.nextPhoto
        reviewedCount = reviewService.reviewedCount
        keptCount = keepAction.keptPhotos.count
        deletedCount = deleteAction.photosToDelete.count
        spaceToFree = deleteAction.spaceToFree
    }

    private func photoCountText(_ count: Int) -> String {
        count == 1 ? "1 photo" : "\(count) photos"
    }

    private func formattedSize(_ bytes: Int64) -> String {
        bytes.formatted(.byteCount(style: .file, allowedUnits: [.mb, .gb], spellsOutZero: false))
    }
}

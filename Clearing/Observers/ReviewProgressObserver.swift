import Foundation

final class ReviewProgressObserver: ReviewSessionObserver {
    private(set) var reviewedCount = 0
    private(set) var totalCount = 0
    private(set) var isComplete = false

    var progress: Double {
        totalCount > 0 ? Double(reviewedCount) / Double(totalCount) : 0
    }

    func update(with event: ReviewSessionEvent) {
        switch event {
        case .started(let totalPhotos):
            totalCount = totalPhotos
            reviewedCount = 0
            isComplete = false
        case .photoKept, .photoDeleted:
            reviewedCount += 1
        case .keepUndone, .deleteUndone:
            reviewedCount -= 1
        case .finished:
            isComplete = true
        }
    }
}

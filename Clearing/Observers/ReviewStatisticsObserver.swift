import Foundation

final class ReviewStatisticsObserver: ReviewSessionObserver {
    private(set) var keptCount = 0
    private(set) var deletedCount = 0
    private(set) var spaceToFree: Int64 = 0

    func update(with event: ReviewSessionEvent) {
        switch event {
        case .started:
            keptCount = 0
            deletedCount = 0
            spaceToFree = 0
        case .photoKept:
            keptCount += 1
        case .keepUndone:
            keptCount -= 1
        case .photoDeleted(let photo):
            deletedCount += 1
            spaceToFree += photo.sizeInBytes
        case .deleteUndone(let photo):
            deletedCount -= 1
            spaceToFree -= photo.sizeInBytes
        case .finished:
            break
        }
    }
}

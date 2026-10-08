import Foundation

final class PhotoReviewService {
    private let repository: PhotoRepository

    private(set) var photos: [Photo] = []
    private(set) var reviewedCount = 0

    init(repository: PhotoRepository) {
        self.repository = repository
        startReview()
    }

    var currentPhoto: Photo? {
        photo(at: reviewedCount)
    }

    var isFinished: Bool {
        reviewedCount >= photos.count
    }

    func startReview() {
        photos = repository.getPhotos()
        reviewedCount = 0
    }

    func apply(_ action: PhotoAction) {
        guard let photo = currentPhoto else { return }
        action.execute(on: photo)
        reviewedCount += 1
    }

    private func photo(at index: Int) -> Photo? {
        photos.indices.contains(index) ? photos[index] : nil
    }
}

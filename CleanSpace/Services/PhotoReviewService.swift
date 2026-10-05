import Foundation

// SRP: this class only contains the review rules:
// which photo is current, what comes next and when the review is finished.
final class PhotoReviewService {
    // DIP: the service depends on the PhotoRepository abstraction,
    // not on a concrete repository implementation.
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

    var nextPhoto: Photo? {
        photo(at: reviewedCount + 1)
    }

    var isFinished: Bool {
        reviewedCount >= photos.count
    }

    func startReview() {
        photos = repository.getPhotos()
        reviewedCount = 0
    }

    // OCP: the service does not know if the action is Keep, Delete or something new.
    func apply(_ action: PhotoAction) {
        guard let photo = currentPhoto else { return }
        action.execute(on: photo)
        reviewedCount += 1
    }

    private func photo(at index: Int) -> Photo? {
        photos.indices.contains(index) ? photos[index] : nil
    }
}

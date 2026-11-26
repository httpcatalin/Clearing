import Foundation

final class PhotoReviewService {
    private var repository: PhotoRepository

    private(set) var photos: [Photo] = []
    private(set) var reviewedCount = 0
    private(set) var mode: ReviewMode = .detailed

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

    func startReview(mode: ReviewMode = .detailed) {
        let session = ReviewSessionBuilder()
            .setPhotos(repository.getPhotos())
            .setStartingIndex(0)
            .setReviewMode(mode)
            .build()
        start(session)
    }

    func changeRepository(to newRepository: PhotoRepository) {
        repository = newRepository
        startReview(mode: mode)
    }

    func start(_ session: ReviewSession) {
        photos = session.photos
        reviewedCount = session.startIndex
        mode = session.mode
    }

    func apply(_ action: PhotoAction) {
        guard let photo = currentPhoto else { return }
        action.execute(on: photo)
        reviewedCount += 1
    }

    func undo(_ action: PhotoAction) {
        guard reviewedCount > 0 else { return }
        reviewedCount -= 1
        guard let photo = currentPhoto else { return }
        action.undo(on: photo)
    }

    private func photo(at index: Int) -> Photo? {
        photos.indices.contains(index) ? photos[index] : nil
    }
}

import Foundation

final class ReviewSessionBuilder {
    private var photos: [Photo] = []
    private var startIndex = 0
    private var mode: ReviewMode = .detailed

    @discardableResult
    func setPhotos(_ photos: [Photo]) -> ReviewSessionBuilder {
        self.photos = photos
        return self
    }

    @discardableResult
    func setStartingIndex(_ index: Int) -> ReviewSessionBuilder {
        startIndex = index
        return self
    }

    @discardableResult
    func setReviewMode(_ mode: ReviewMode) -> ReviewSessionBuilder {
        self.mode = mode
        return self
    }

    func build() -> ReviewSession {
        ReviewSession(photos: photos, startIndex: validStartIndex, mode: mode)
    }

    private var validStartIndex: Int {
        guard !photos.isEmpty else { return 0 }
        return min(max(startIndex, 0), photos.count - 1)
    }
}

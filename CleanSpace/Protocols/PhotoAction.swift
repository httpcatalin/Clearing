import Foundation

// OCP: PhotoReviewService works with any PhotoAction.
// A new action (for example FavoritePhotoAction) is added as a new type,
// without changing the review service.
protocol PhotoAction {
    func execute(on photo: Photo)
}

import Foundation

final class DeletePhotoCommand: PhotoCommand {
    private let photo: Photo
    private let action: PhotoAction
    private let reviewService: PhotoReviewService
    private let subject: ReviewSessionSubject

    init(photo: Photo, action: PhotoAction, reviewService: PhotoReviewService, subject: ReviewSessionSubject) {
        self.photo = photo
        self.action = action
        self.reviewService = reviewService
        self.subject = subject
    }

    func execute() {
        reviewService.apply(action)
        subject.notify(.photoDeleted(photo))
    }

    func undo() {
        reviewService.undo(action)
        subject.notify(.deleteUndone(photo))
    }
}

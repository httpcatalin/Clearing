import Foundation

final class ReadyState: ReviewSessionState {
    func start(mode: ReviewMode, in context: ReviewSessionContext) {
        context.prepareReview(mode: mode)
        context.transition(to: ReviewingState())
        context.finishIfEveryPhotoIsReviewed()
    }
}

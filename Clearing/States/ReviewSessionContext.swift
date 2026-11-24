import Foundation

final class ReviewSessionContext {
    private(set) var state: ReviewSessionState = ReadyState()
    let commandManager = PhotoCommandManager()

    private let reviewService: PhotoReviewService
    private let subject: ReviewSessionSubject

    init(reviewService: PhotoReviewService, subject: ReviewSessionSubject) {
        self.reviewService = reviewService
        self.subject = subject
    }

    var canDecide: Bool {
        state.canDecide
    }

    var isPaused: Bool {
        state.isPaused
    }

    var canUndo: Bool {
        state.canDecide && commandManager.canUndo
    }

    func start(mode: ReviewMode) {
        state.start(mode: mode, in: self)
    }

    func pause() {
        state.pause(in: self)
    }

    func resume() {
        state.resume(in: self)
    }

    func perform(_ command: PhotoCommand) {
        state.perform(command, in: self)
    }

    func undo() {
        state.undo(in: self)
    }

    func close() {
        state.close(in: self)
    }

    func transition(to newState: ReviewSessionState) {
        state = newState
    }

    func prepareReview(mode: ReviewMode) {
        reviewService.startReview(mode: mode)
        commandManager.clearHistory()
        subject.notify(.started(totalPhotos: reviewService.photos.count))
    }

    func finishIfEveryPhotoIsReviewed() {
        guard reviewService.isFinished else { return }
        transition(to: FinishedState())
        subject.notify(.finished)
    }
}

import Foundation

final class ReviewingState: ReviewSessionState {
    var canDecide: Bool { true }

    func pause(in context: ReviewSessionContext) {
        context.transition(to: PausedState())
    }

    func perform(_ command: PhotoCommand, in context: ReviewSessionContext) {
        context.commandManager.execute(command)
        context.finishIfEveryPhotoIsReviewed()
    }

    func undo(in context: ReviewSessionContext) {
        context.commandManager.undoLast()
    }

    func close(in context: ReviewSessionContext) {
        context.transition(to: ReadyState())
    }
}

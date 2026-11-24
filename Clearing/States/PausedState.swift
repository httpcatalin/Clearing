import Foundation

final class PausedState: ReviewSessionState {
    var isPaused: Bool { true }

    func resume(in context: ReviewSessionContext) {
        context.transition(to: ReviewingState())
    }

    func close(in context: ReviewSessionContext) {
        context.transition(to: ReadyState())
    }
}

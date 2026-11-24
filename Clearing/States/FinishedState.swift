import Foundation

final class FinishedState: ReviewSessionState {
    func close(in context: ReviewSessionContext) {
        context.transition(to: ReadyState())
    }
}

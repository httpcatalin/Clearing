import Foundation

protocol ReviewSessionState {
    var canDecide: Bool { get }
    var isPaused: Bool { get }

    func start(mode: ReviewMode, in context: ReviewSessionContext)
    func pause(in context: ReviewSessionContext)
    func resume(in context: ReviewSessionContext)
    func perform(_ command: PhotoCommand, in context: ReviewSessionContext)
    func undo(in context: ReviewSessionContext)
    func close(in context: ReviewSessionContext)
}

extension ReviewSessionState {
    var canDecide: Bool { false }
    var isPaused: Bool { false }

    func start(mode: ReviewMode, in context: ReviewSessionContext) {}
    func pause(in context: ReviewSessionContext) {}
    func resume(in context: ReviewSessionContext) {}
    func perform(_ command: PhotoCommand, in context: ReviewSessionContext) {}
    func undo(in context: ReviewSessionContext) {}
    func close(in context: ReviewSessionContext) {}
}

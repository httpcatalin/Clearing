import Foundation

final class PhotoCommandManager {
    private var history: [PhotoCommand] = []

    var canUndo: Bool {
        !history.isEmpty
    }

    func execute(_ command: PhotoCommand) {
        command.execute()
        history.append(command)
    }

    func undoLast() {
        history.popLast()?.undo()
    }

    func clearHistory() {
        history.removeAll()
    }
}

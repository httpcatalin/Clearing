import Foundation

// multe fisiere pentru o actiune simpla
// lista ocupa memorie: un obiect pentru fiecare poza asa ii rau
// zato tine minte tot
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

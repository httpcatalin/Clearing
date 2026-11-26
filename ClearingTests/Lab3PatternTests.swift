import Testing
@testable import Clearing

private final class RecordingObserver: ReviewSessionObserver {
    private(set) var events: [ReviewSessionEvent] = []

    func update(with event: ReviewSessionEvent) {
        events.append(event)
    }
}

private final class CountingCommand: PhotoCommand {
    private(set) var executeCount = 0
    private(set) var undoCount = 0

    func execute() {
        executeCount += 1
    }

    func undo() {
        undoCount += 1
    }
}

private struct EmptyPhotoRepository: PhotoRepository {
    func getPhotos() -> [Photo] {
        []
    }
}

private func makeViewModel() -> PhotoReviewViewModel {
    PhotoReviewViewModel(
        facade: PhotoReviewFacade(
            libraryRepository: LocalPhotoRepository(),
            archiveRepository: LocalPhotoRepository(),
            keepActionFactory: KeepPhotoActionFactory(),
            deleteActionFactory: DeletePhotoActionFactory()
        )
    )
}

private func makeContext(repository: PhotoRepository = LocalPhotoRepository()) -> ReviewSessionContext {
    ReviewSessionContext(reviewService: PhotoReviewService(repository: repository), subject: ReviewSessionSubject())
}

struct CommandTests {
    @Test func keepCommandAppliesAndUndoesTheDecision() {
        let service = PhotoReviewService(repository: LocalPhotoRepository())
        let action = KeepPhotoAction()
        let photo = service.photos[0]
        let command = KeepPhotoCommand(photo: photo, action: action, reviewService: service, subject: ReviewSessionSubject())

        command.execute()
        #expect(action.keptPhotos == [photo])
        #expect(service.currentPhoto == service.photos[1])

        command.undo()
        #expect(action.keptPhotos.isEmpty)
        #expect(service.currentPhoto == photo)
    }

    @Test func deleteCommandAppliesAndUndoesTheDecision() {
        let service = PhotoReviewService(repository: LocalPhotoRepository())
        let action = DeletePhotoAction()
        let photo = service.photos[0]
        let command = DeletePhotoCommand(photo: photo, action: action, reviewService: service, subject: ReviewSessionSubject())

        command.execute()
        #expect(action.photosToDelete == [photo])

        command.undo()
        #expect(action.photosToDelete.isEmpty)
        #expect(service.currentPhoto == photo)
    }

    @Test func managerUndoesInReverseOrder() {
        let manager = PhotoCommandManager()
        let first = CountingCommand()
        let second = CountingCommand()

        manager.execute(first)
        manager.execute(second)
        manager.undoLast()

        #expect(second.undoCount == 1)
        #expect(first.undoCount == 0)
        #expect(manager.canUndo)

        manager.undoLast()

        #expect(first.undoCount == 1)
        #expect(manager.canUndo == false)
    }

    @Test func undoWithEmptyHistoryIsSafe() {
        let manager = PhotoCommandManager()

        manager.undoLast()

        #expect(manager.canUndo == false)
    }

    @Test func undoBringsBackThePhotoInTheViewModel() {
        let viewModel = makeViewModel()
        viewModel.startReview()
        let photo = viewModel.currentPhoto

        viewModel.deleteCurrentPhoto()
        #expect(viewModel.currentPhoto != photo)
        #expect(viewModel.canUndo)

        viewModel.undoLastDecision()

        #expect(viewModel.currentPhoto == photo)
        #expect(viewModel.removedPhotoIDs.isEmpty)
        #expect(viewModel.canUndo == false)
    }
}

struct ObserverTests {
    @Test func subjectNotifiesEveryAttachedObserver() {
        let subject = ReviewSessionSubject()
        let first = RecordingObserver()
        let second = RecordingObserver()
        subject.attach(first)
        subject.attach(second)

        subject.notify(.finished)

        #expect(first.events.count == 1)
        #expect(second.events.count == 1)
    }

    @Test func detachedObserverGetsNoEvents() {
        let subject = ReviewSessionSubject()
        let observer = RecordingObserver()
        subject.attach(observer)
        subject.detach(observer)

        subject.notify(.finished)

        #expect(observer.events.isEmpty)
    }

    @Test func progressObserverFollowsTheEvents() {
        let observer = ReviewProgressObserver()
        let photo = Photo(imageName: "sample-01", sizeInBytes: 100)

        observer.update(with: .started(totalPhotos: 2))
        observer.update(with: .photoKept(photo))
        #expect(observer.reviewedCount == 1)
        #expect(observer.progress == 0.5)

        observer.update(with: .keepUndone(photo))
        #expect(observer.reviewedCount == 0)

        observer.update(with: .finished)
        #expect(observer.isComplete)

        observer.update(with: .started(totalPhotos: 2))
        #expect(observer.isComplete == false)
    }

    @Test func statisticsObserverStaysCorrectAfterUndo() {
        let observer = ReviewStatisticsObserver()
        let photo = Photo(imageName: "sample-01", sizeInBytes: 100)

        observer.update(with: .photoDeleted(photo))
        #expect(observer.deletedCount == 1)
        #expect(observer.spaceToFree == 100)

        observer.update(with: .deleteUndone(photo))
        #expect(observer.deletedCount == 0)
        #expect(observer.spaceToFree == 0)

        observer.update(with: .photoKept(photo))
        observer.update(with: .started(totalPhotos: 1))
        #expect(observer.keptCount == 0)
    }

    @Test func commandsNotifyObservers() {
        let service = PhotoReviewService(repository: LocalPhotoRepository())
        let subject = ReviewSessionSubject()
        let observer = RecordingObserver()
        subject.attach(observer)
        let command = KeepPhotoCommand(photo: service.photos[0], action: KeepPhotoAction(), reviewService: service, subject: subject)

        command.execute()
        command.undo()

        #expect(observer.events.count == 2)
    }

    @Test func viewModelStatisticsReturnAfterUndo() {
        let viewModel = makeViewModel()
        viewModel.startReview()

        viewModel.keepCurrentPhoto()
        viewModel.deleteCurrentPhoto()
        #expect(viewModel.reviewedCount == 2)
        #expect(viewModel.keptCount == 1)
        #expect(viewModel.deletedCount == 1)
        #expect(viewModel.spaceToFree > 0)

        viewModel.undoLastDecision()

        #expect(viewModel.reviewedCount == 1)
        #expect(viewModel.keptCount == 1)
        #expect(viewModel.deletedCount == 0)
        #expect(viewModel.spaceToFree == 0)
    }
}

struct StateTests {
    @Test func aNewSessionIsReady() {
        #expect(makeContext().state is ReadyState)
    }

    @Test func followsTheWholeLifecycle() {
        let context = makeContext()

        context.start(mode: .detailed)
        #expect(context.state is ReviewingState)

        context.pause()
        #expect(context.state is PausedState)

        context.resume()
        #expect(context.state is ReviewingState)

        context.close()
        #expect(context.state is ReadyState)
    }

    @Test func invalidTransitionsAreIgnored() {
        let context = makeContext()

        context.pause()
        context.resume()
        context.close()
        #expect(context.state is ReadyState)

        context.start(mode: .detailed)
        context.resume()
        context.start(mode: .detailed)
        #expect(context.state is ReviewingState)

        context.pause()
        context.pause()
        context.start(mode: .detailed)
        #expect(context.state is PausedState)
    }

    @Test func onlyReviewingAcceptsCommands() {
        let context = makeContext()
        let command = CountingCommand()

        context.perform(command)
        #expect(command.executeCount == 0)

        context.start(mode: .detailed)
        context.perform(command)
        #expect(command.executeCount == 1)

        context.pause()
        context.perform(command)
        context.undo()
        #expect(command.executeCount == 1)
        #expect(command.undoCount == 0)

        context.resume()
        context.undo()
        #expect(command.undoCount == 1)
    }

    @Test func emptyLibraryFinishesRightAway() {
        let context = makeContext(repository: EmptyPhotoRepository())

        context.start(mode: .detailed)

        #expect(context.state is FinishedState)
    }

    @Test func pausedViewModelIgnoresDecisions() {
        let viewModel = makeViewModel()
        viewModel.startReview()
        viewModel.keepCurrentPhoto()
        viewModel.pauseReview()

        viewModel.keepCurrentPhoto()
        viewModel.deleteCurrentPhoto()
        viewModel.undoLastDecision()

        #expect(viewModel.isPaused)
        #expect(viewModel.canDecide == false)
        #expect(viewModel.canUndo == false)
        #expect(viewModel.reviewedCount == 1)

        viewModel.resumeReview()
        viewModel.keepCurrentPhoto()

        #expect(viewModel.isPaused == false)
        #expect(viewModel.reviewedCount == 2)
    }

    @Test func finishedSessionRejectsDecisionsUntilANewOneStarts() {
        let viewModel = makeViewModel()
        viewModel.startReview()
        for _ in 0..<viewModel.totalCount {
            viewModel.deleteCurrentPhoto()
        }
        let deleted = viewModel.deletedCount

        viewModel.undoLastDecision()
        viewModel.keepCurrentPhoto()

        #expect(viewModel.isFinished)
        #expect(viewModel.canUndo == false)
        #expect(viewModel.deletedCount == deleted)

        viewModel.closeReview()
        viewModel.startReview()

        #expect(viewModel.isFinished == false)
        #expect(viewModel.canDecide)
        #expect(viewModel.reviewedCount == 0)
        #expect(viewModel.deletedCount == 0)
    }

    @Test func aNewSessionHasNothingToUndo() {
        let viewModel = makeViewModel()
        viewModel.startReview()
        viewModel.keepCurrentPhoto()

        viewModel.startReview()

        #expect(viewModel.canUndo == false)
    }
}

import Foundation

final class ReviewSessionSubject {
    private var observers: [ReviewSessionObserver] = []

    func attach(_ observer: ReviewSessionObserver) {
        observers.append(observer)
    }

    func detach(_ observer: ReviewSessionObserver) {
        observers.removeAll { $0 === observer }
    }

    func notify(_ event: ReviewSessionEvent) {
        for observer in observers {
            observer.update(with: event)
        }
    }
}

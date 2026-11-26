import Foundation

//inainte calcula singur toate cifrelel, acum fiecare numaratoare are clase ei si se actualizeaza automat cand primeste notify
// ii scalabil, pot dupa sa adaug cu ai sters 100 de fotografii achievement

// ii greu de urmarit, trebuie sa caut abonatii, si stau in memorie pana fac detach
enum ReviewSessionEvent {
    case started(totalPhotos: Int)
    case photoKept(Photo)
    case photoDeleted(Photo)
    case keepUndone(Photo)
    case deleteUndone(Photo)
    case finished
}

protocol ReviewSessionObserver: AnyObject {
    func update(with event: ReviewSessionEvent)
}

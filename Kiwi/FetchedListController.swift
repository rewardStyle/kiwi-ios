//
// FetchedListController.swift
//
// Copyright (c) 2019 InQBarna Kenkyuu Jo (http://inqbarna.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
import CoreData

open class FetchedListController<R: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    public typealias Item = R
    private var weakObservers = WeakSet<AnyObject>()
    public internal(set) var state: ControllerState
    public let fetchedResultsController: NSFetchedResultsController<R>

    public init(fetchRequest: NSFetchRequest<R>, context: NSManagedObjectContext) {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        do {
            try fetchedResultsController.performFetch()
            state = .loaded
        } catch {
            state = .error(error)
        }

        super.init()
        fetchedResultsController.delegate = self
    }

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyWillChangeContent()
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            guard let index = newIndexPath?.row else {
                return
            }
            notifyDid(.insert(at: index))

        case .delete:
            guard let index = indexPath?.row else {
                return
            }

            notifyDid(.delete(at: index))
        case .move:
            guard
                let index = indexPath?.row,
                let newIndex = newIndexPath?.row
            else {
                return
            }
            notifyDid(.move(from: index, to: newIndex))

        case .update:
            guard let index = indexPath?.row else {
                return
            }

            notifyDid(.update(at: index))
        @unknown default:
            fatalError()
        }
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyDidChangeContent()
    }

}

extension FetchedListController: ObservableController {
    public func setState(_ state: ControllerState) {
        let fromState = self.state
        self.state = state
        for observer in observers {
            observer.controller(self, didChange: fromState, to: state)
        }
    }

    public var observers: [ControllerObserver] {
        return weakObservers.allObjects as! [ControllerObserver]
    }

    public func addObserver(_ observer: ControllerObserver) {
        weakObservers.insert(observer)
    }

    public func removeObserver(_ observer: ControllerObserver) {
        weakObservers.remove(observer)
    }
}

extension FetchedListController: ListController {
    public var numberOfItems: Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    public func itemAt(_ index: Int) -> R? {
        return fetchedResultsController.fetchedObjects![index]
    }

    public func indexOf(_ item: R) -> Int? {
        return fetchedResultsController.fetchedObjects?.firstIndex(of: item)
    }

    public func stateAt(_ index: Int) -> ControllerState {
        return .loaded
    }
}

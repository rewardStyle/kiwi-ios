//
// ManagedObjectController.swift
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

public class ManagedObjectController {
    private var weakObservers = WeakSet<AnyObject>()
    let object: NSManagedObject
    let keys: [String]

    public private(set) var state: ControllerState

    public init(object: NSManagedObject, keys: [String]? = nil) {
        self.object = object
        self.keys = keys ?? []
        state = .loaded

        guard let context = object.managedObjectContext else {
            return
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextDidChange(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: context)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - ManagedObjectInteractor methods

    @objc func contextDidChange(notification: NSNotification) {

        guard let userInfo = notification.userInfo else {
            return
        }

        if
            let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
            !updatedObjects.isEmpty
        {
            if updatedObjects.contains(object) {
                setState(.loaded)
                return
            }

            for key in keys {
                if
                    let value = object.value(forKey: key) as? NSSet,
                    value.intersects(updatedObjects)
                {
                    setState(.loaded)
                    return
                }
                else if
                    let value = object.value(forKey: key) as? NSOrderedSet,
                    value.intersectsSet(updatedObjects)
                {
                    setState(.loaded)
                    return
                } else if
                    let value = object.value(forKey: key) as? NSManagedObject,
                    updatedObjects.contains(value)
                {
                    setState(.loaded)
                    return
                }
            }
        }

        if
            let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
            !deletedObjects.isEmpty,
            deletedObjects.contains(object)
        {
            setState(.error(NSError(domain: "coreData", code: 404, userInfo: [NSLocalizedDescriptionKey: "Object no longer available"])))
            return
        }

        if
            let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
            !refreshedObjects.isEmpty,
            refreshedObjects.contains(object)
        {
            setState(.loaded)
            return
        }
    }
}

extension ManagedObjectController: ObservableController {

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

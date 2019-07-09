//
// ArrayListController.swift
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

class ArrayListController<R: Hashable> {
    typealias Item = R
    private var weakObservers = WeakSet<AnyObject>()
    internal var items: [R]
    internal var state: ControllerState

    init(items: [R]) {
        self.items = items
        self.state = .loaded
    }

    func append(_ item: R) {
        notifyWillChangeContent()
        let index = items.count
        items.append(item)
        notifyDid(.insert(at: index))
        notifyDidChangeContent()
    }

    func remove(_ index: Int) {
        notifyWillChangeContent()
        items.remove(at: index)
        notifyDid(.delete(at: index))
        notifyDidChangeContent()
    }

    func insert(_ item: R, at index: Int) {
        notifyWillChangeContent()
        items.insert(item, at: index)
        notifyDid(.insert(at: index))
        notifyDidChangeContent()
    }

    func move(from: Int, to: Int) {
        notifyWillChangeContent()
        let item = items[from]
        items.remove(at: from)
        items.insert(item, at: to)
        notifyDid(.move(from: from, to: to))
        notifyDidChangeContent()
    }
}

extension ArrayListController: ObservableController {
    func setState(_ state: ControllerState) {
        let fromState = self.state
        self.state = state
        for observer in observers {
            observer.controller(self, didChange: fromState, to: state)
        }
    }

    var observers: [ControllerObserver] {
        return weakObservers.allObjects as! [ControllerObserver]
    }

    func addObserver(_ observer: ControllerObserver) {
        weakObservers.insert(observer)
    }

    func removeObserver(_ observer: ControllerObserver) {
        weakObservers.remove(observer)
    }
}

extension ArrayListController: ListController {
    var numberOfItems: Int {
        return items.count
    }

    func itemAt(_ index: Int) -> R? {
        return items[index]
    }

    func indexOf(_ item: R) -> Int? {
        return nil
    }

    func stateAt(_ index: Int) -> ControllerState {
        return .loaded
    }
}

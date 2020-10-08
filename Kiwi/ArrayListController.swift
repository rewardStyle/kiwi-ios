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

open class ArrayListController<R: Hashable> {
    public typealias Item = R
    private var weakObservers = WeakSet<AnyObject>()
    internal var items: [R]
    public internal(set) var state: ControllerState

    public init(items: [R]) {
        self.items = items
        self.state = .loaded
    }

    public func append(_ item: R) {
        notifyWillChangeContent()
        let index = items.count
        items.append(item)
        notifyDid(.insert(at: index))
        notifyDidChangeContent()
    }

    public func remove(_ index: Int) {
        notifyWillChangeContent()
        items.remove(at: index)
        notifyDid(.delete(at: index))
        notifyDidChangeContent()
    }

    public func insert(_ item: R, at index: Int) {
        notifyWillChangeContent()
        items.insert(item, at: index)
        notifyDid(.insert(at: index))
        notifyDidChangeContent()
    }

    public func move(from: Int, to: Int) {
        notifyWillChangeContent()
        let item = items[from]
        items.remove(at: from)
        items.insert(item, at: to)
        notifyDid(.move(from: from, to: to))
        notifyDidChangeContent()
    }

    public func setItems(_ items: [R]) {
        self.items.removeAll()
        self.items.append(contentsOf: items)
        setState(.loaded)
    }

    public func allItems() -> [R] {
        return items
    }
}

extension ArrayListController: ObservableController {
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

    func removeObserver(_ observer: ControllerObserver) {
        weakObservers.remove(observer)
    }
}

extension ArrayListController: ListController {
    public var numberOfItems: Int {
        return items.count
    }

    public func itemAt(_ index: Int) -> R? {
        return items[index]
    }

    public func indexOf(_ item: R) -> Int? {
        return nil
    }

    public func stateAt(_ index: Int) -> ControllerState {
        return .loaded
    }
}

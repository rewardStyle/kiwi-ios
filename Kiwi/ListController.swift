//
// ListController.swift
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

public enum ChangeType {
    case insert(at: Int)
    case delete(at: Int)
    case move(from: Int, to: Int)
    case update(at: Int)
}

public protocol ListControllerObserver: ControllerObserver {
    func listControllerWillChangeContent(_ controller: StatefulController)
    func listController(_ controller: StatefulController, did changeType: ChangeType)
    func listControllerDidChangeContent(_ controller: StatefulController)
}

public protocol ListController: ObservableController {
    associatedtype Item

    var numberOfItems: Int { get }
    func itemAt(_ index: Int) -> Item?
    func indexOf(_ item: Item) -> Int?
    func stateAt(_ index: Int) -> ControllerState
}

extension ListController {
    public func notifyWillChangeContent() {
        for observer in observers {
            guard let observer = observer as? ListControllerObserver else {
                continue
            }
            observer.listControllerWillChangeContent(self)
        }
    }

    public func notifyDid(_ changeType: ChangeType) {
        for observer in observers {
            guard let observer = observer as? ListControllerObserver else {
                continue
            }
            observer.listController(self, did: changeType)
        }
    }

    public func notifyDidChangeContent() {
        for observer in observers {
            guard let observer = observer as? ListControllerObserver else {
                continue
            }
            observer.listControllerDidChangeContent(self)
        }
    }
}

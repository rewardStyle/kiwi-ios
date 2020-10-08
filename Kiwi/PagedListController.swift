//
// PagedListController.swift
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

public protocol URIdentifiable {
    var uri: URL { get }
}

public protocol ObjectStore {
    func object<T: URIdentifiable>(_ url: URL) -> T?
}

public protocol PageSource {
    var objectStore: ObjectStore! { get }
    func get<T: URIdentifiable>(page: Int, size: Int, completion: ((Int, [T]?, Error?) -> Void)?)
}

class ListControllerPage {
    var number: Int
    var size: Int
    var items: [ListControllerItem] = []
    var state = ControllerState.notLoaded
    var fetchTime: TimeInterval = 0
    var needsRefresh = false

    init(number: Int, length: Int) {
        self.number = number
        self.size = length
    }
}

class ListControllerItem {
    var uri: URL?
    weak var page: ListControllerPage?

    init(page: ListControllerPage) {
        self.page = page
    }
}

open class PagedListController<R: URIdentifiable>: NSObject {
    private var weakObservers = WeakSet<AnyObject>()
    public internal(set) var state: ControllerState
    internal let objectStore: ObjectStore
    internal let pageSource: PageSource

    public var itemsPerPage: Int = 20
    var items: [ListControllerItem] = []
    var pages: [ListControllerPage] = []

    public init(pageSource: PageSource) {
        self.objectStore = pageSource.objectStore
        self.pageSource = pageSource
        state = .notLoaded
    }

    public func loadList() {
//        switch state {
//        case .loaded, .notLoaded, .error(_):
//            break
//
//        case .loading: fatalError()
//        }

        items.removeAll()
        pages.removeAll()
        fetchPage(0) { (error) in
        }
    }

    public func load(_ index: Int) {

        guard index < items.count else {
            return
        }

        let item = items[index]
        if
            let page = item.page,
            case .notLoaded = page.state
        {
            fetchPage(page.number, completion: { (error) in

            })
        }
    }

    public func fetchPage(_ index: Int, completion: @escaping (Error?) -> Void) {

        var page: ListControllerPage?

        if index < pages.count {
            let p = pages[index]
            p.state = .loading
            page = p
        } else {
            setState(.loading)
        }

        pageSource.get(page: index, size: itemsPerPage) { [weak self] (totalCount: Int, objects: [R]?, error: Error?) in

            guard let self = self else {
                return
            }

            if let error = error {
                page?.state = .error(error)
                self.setState(.error(error))
                completion(error)
            } else {
                if page == nil {
                    // first run
                    self.createItemsAndPages(totalCount: totalCount)
                    if let p = self.pages.first {
                        page = p
                    }
                }

                if let page = page {
                    self.update(page: page, objects: objects!)
                } else {
                    fatalError()
                }

                switch self.state {
                case .loading:
                    self.setState(.loaded)

                case .loaded:
                    break
                case .notLoaded, .error(_):
                    fatalError()
                }
                completion(nil)
            }
        }
    }

    private func createItemsAndPages(totalCount: Int) {

        guard totalCount > 0 else {
            self.items = []
            self.pages = [ListControllerPage(number: 0, length: 0)]
            return
        }

        var items: [ListControllerItem] = []
        var pages: [ListControllerPage] = []

        var remaining = totalCount

        while remaining > 0 {

            let size = remaining >= itemsPerPage ? itemsPerPage : remaining

            let page = ListControllerPage(number: pages.count, length: size)
            pages.append(page)

            var pageItems: [ListControllerItem] = []

            for _ in 0..<size {
                let item = ListControllerItem(page: page)
                pageItems.append(item)
                items.append(item)
            }

            page.items = pageItems
            remaining -= size
        }

        self.items = items
        self.pages = pages
    }

    private func update(page: ListControllerPage, objects: [R]) {

        for (index, object) in objects.enumerated() {
            if index < page.size {
                page.items[index].uri = object.uri
            } else {
                fatalError()
            }
        }

        page.state = .loaded

        if case .loaded = state {
            notifyWillChangeContent()

            for (index, _) in page.items.enumerated() {
                notifyDid(.update(at: page.number * itemsPerPage + index))
            }
            notifyDidChangeContent()
        }
    }
}

extension PagedListController: ObservableController {
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

extension PagedListController: ListController {
    public typealias Item = R

    public var numberOfItems: Int {
        return items.count
    }

    public func itemAt(_ index: Int) -> R? {
        guard
            index < items.count,
            let uri = items[index].uri
        else {
            return nil
        }

        let result: R? = objectStore.object(uri)
        return result
    }

    public func indexOf(_ item: R) -> Int? {

        for (index, internalObject) in items.enumerated() {
            if
                let uri = internalObject.uri,
                uri == item.uri
            {
                return index
            }
        }

        return nil
    }

    public func stateAt(_ index: Int) -> ControllerState {
        guard
            index < items.count,
            let page = items[index].page
        else {
            return .notLoaded
        }

        return page.state
    }
}

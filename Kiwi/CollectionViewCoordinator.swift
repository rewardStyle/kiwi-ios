//
// CollectionViewCoordinator.swift
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

import UIKit

public class CollectionViewCoordinator {
    private weak var collectionView: UICollectionView?
    private var controller: ObservableController
    public var animateChanges: Bool = false
    private let section: Int

    // MARK: - InteractorTableViewManager methods

    public init(controller: ObservableController, collectionView: UICollectionView, section: Int = 0) {
        self.collectionView = collectionView
        self.controller = controller
        self.section = section
        self.controller.addObserver(self)
    }

    deinit {
        self.controller.removeObserver(self)
    }
}

extension CollectionViewCoordinator: ListControllerObserver {
    public func controller(_ controller: StatefulController, didChange fromState: ControllerState, to state: ControllerState) {
        collectionView?.reloadData()
    }

    public func listControllerWillChangeContent(_ controller: StatefulController) {
        // TODO
    }

    public func listController(_ controller: StatefulController, did changeType: ChangeType) {
        // TODO
    }

    public func listControllerDidChangeContent(_ controller: StatefulController) {
        // TODO
        collectionView?.reloadData()
    }
}

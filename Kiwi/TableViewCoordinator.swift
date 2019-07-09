//
// TableViewCoordinator.swift
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

public class TableViewCoordinator {
    private weak var tableView: UITableView?
    private var controller: ObservableController
    public var animateChanges: Bool = false
    private let section: Int

    // MARK: - InteractorTableViewManager methods

    public init(controller: ObservableController, tableView: UITableView, section: Int = 0) {
        self.tableView = tableView
        self.controller = controller
        self.section = section
        self.controller.addObserver(self)
    }

    deinit {
        self.controller.removeObserver(self)
    }
}

extension TableViewCoordinator: ListControllerObserver {
    public func controller(_ controller: StatefulController, didChange fromState: ControllerState, to state: ControllerState) {
        tableView?.reloadData()
    }

    public func listControllerWillChangeContent(_ controller: StatefulController) {
        guard
            let tableView = tableView,
            animateChanges
        else {
            return
        }

        tableView.beginUpdates()
    }

    public func listController(_ controller: StatefulController, did changeType: ChangeType) {
        guard
            let tableView = tableView,
            animateChanges
        else {
            return
        }

        switch changeType {
        case .insert(at: let index):
            tableView.insertRows(at: [IndexPath(row: index, section: section)], with: .fade)

        case .delete(at: let index):
            tableView.deleteRows(at: [IndexPath(row: index, section: section)], with: .fade)

        case .update(at: let index):
            tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: .fade)

        case .move(from: let fromIndex, to: let toIndex):
            tableView.moveRow(at: IndexPath(row: fromIndex, section: section), to: IndexPath(row: toIndex, section: section))
        }
    }

    public func listControllerDidChangeContent(_ controller: StatefulController) {
        guard let tableView = tableView else {
            return
        }

        if animateChanges {
            tableView.endUpdates()
        } else {
            tableView.reloadData()
        }
    }
}

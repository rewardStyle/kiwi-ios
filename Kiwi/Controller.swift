//
// Controller.swift
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

public enum ControllerState: Equatable {
    case notLoaded
    case loading
    case loaded
    case error(_ error: Error)

    public static func == (lhs: ControllerState, rhs: ControllerState) -> Bool {
        switch (lhs, rhs) {
        case (.notLoaded, .notLoaded): return true
        case (.loading, .loading): return true
        case (.loaded, .loaded): return true
        case (.error(_), .error(_)): return true
        default: return false
        }
    }
}

public protocol StatefulController {
    var state: ControllerState { get }
    func setState(_ state: ControllerState)
}

public protocol ControllerObserver: class {
    func controller(_ controller: StatefulController, didChange fromState: ControllerState, to state: ControllerState)
}

public protocol ObservableController: StatefulController {
    var observers: [ControllerObserver] { get }
    func addObserver(_ observer: ControllerObserver)
    func removeObserver(_ observer: ControllerObserver)
}

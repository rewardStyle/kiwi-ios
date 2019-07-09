//
// WeakSet.swift
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

public class WeakSet<T: AnyObject>: Sequence, ExpressibleByArrayLiteral, CustomStringConvertible, CustomDebugStringConvertible {

    private var objects = NSHashTable<T>.weakObjects()

    public init(_ objects: [T]) {
        for object in objects {
            insert(object)
        }
    }

    public convenience required init(arrayLiteral elements: T...) {
        self.init(elements)
    }

    public var allObjects: [T] {
        return objects.allObjects
    }

    public var count: Int {
        return objects.count
    }

    public func contains(_ object: T) -> Bool {
        return objects.contains(object)
    }

    public func insert(_ object: T) {
        objects.add(object)
    }

    public func remove(_ object: T) {
        objects.remove(object)
    }

    public func makeIterator() -> AnyIterator<T> {
        let iterator = objects.objectEnumerator()
        return AnyIterator {
            return iterator.nextObject() as? T
        }
    }

    public var description: String {
        return objects.description
    }

    public var debugDescription: String {
        return objects.debugDescription
    }
}

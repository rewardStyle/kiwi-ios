//
// ManagedPagedListController.swift
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

open class ManagedPagedListController<R: NSManagedObject & URIdentifiable>: PagedListController<R> {
	private let managedContext: NSManagedObjectContext

	@available (*, unavailable)
	override init(pageSource: PageSource) {
		fatalError()
	}

	public init(pageSource: PageSource, managedContext: NSManagedObjectContext) {
		self.managedContext = managedContext
		super.init(pageSource: pageSource)

		NotificationCenter.default.addObserver(self,
											   selector: #selector(contextDidChange(notification:)),
											   name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
											   object: managedContext)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	@objc func contextDidChange(notification: NSNotification) {
		guard let userInfo = notification.userInfo else {
			return
		}

		if
			let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
			!updatedObjects.isEmpty
		{
			var objects: [R] = []

			updatedObjects.forEach { managedObject in
				switch managedObject {
				case let object as R:
					objects.append(object)
				default: break
				}
			}

			if !objects.isEmpty, case .loaded = state {
				notifyWillChangeContent()
				objects.forEach {
					if let updatedIndex = indexOf($0) {
						notifyDid(.update(at: updatedIndex))
					}
				}
				notifyDidChangeContent()
			}

		}

		//TODO: deleted, refreshed
		/**
		if
		let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
		!deletedObjects.isEmpty
		{
		setState(.error(NSError(domain: "coreData", code: 404, userInfo: [NSLocalizedDescriptionKey: "Object no longer available"])))
		return
		}

		if
		let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>,
		!refreshedObjects.isEmpty
		{
		setState(.loaded)
		return
		}
		**/
	}
}

//
//  Stack.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 27/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation

class LinkedListElement<T> {
    
    let element: T
    var next: LinkedListElement<T>?
    
    init(element: T, next: LinkedListElement<T>? = nil) {
        self.element = element
        self.next = next
    }
    
    func toArray() -> [T] {
        guard var array = self.next?.toArray() else {
            return [self.element]
        }
        array.insert(self.element, at: 0)
        return array
    }
}

class Stack<T> {
    
    private var elt: LinkedListElement<T>? = nil
    private var count: Int = 0
    
    var isEmpty: Bool {
        return count == 0
    }
    
    func getCount() -> Int {
        return count
    }
    
    func push(elt: T) -> Void {
        self.elt = LinkedListElement(element: elt, next: self.elt)
        self.count = self.count + 1
    }
    
    func pop() -> T? {
        let top = self.elt?.element
        self.elt = self.elt?.next
        return top
    }
    
    func peek() -> T? {
        return self.elt?.element
    }
    
    func asArray() -> [T] {
        return self.elt?.toArray() ?? []
    }
    
    func removeAll() -> Void {
        self.elt = nil
        self.count = 0
    }
}


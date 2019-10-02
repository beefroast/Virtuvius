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
    
    func getTail() -> LinkedListElement<T>? {
        return next?.getTail() ?? self
    }
    
    func removeWhere(shouldRemove: (T) -> Bool) -> (LinkedListElement<T>, LinkedListElement<T>, Int)? {
        
        let x = self.next?.removeWhere(shouldRemove: shouldRemove)
        
        // If we should remove this, just return the result of removing from
        // the rest of the list...
        if shouldRemove(self.element) {
            return x
        }
        
        // Update the 'next' on this element
        self.next = x?.0
        
        // If we shouldn't, return the end of the last list
        return (
            
            // The head of the previous element's tail is this element.
            self,
            
            // The final of the previous element's tail is the final of this, or this if there are no more
            // elements after it.
            x?.1 ?? self,
            
            // The count of the elements is one plus the count of the tail
            (x?.2 ?? 0) + 1
        )
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
        self.count = self.count - 1
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


class StackQueue<T> {
    
    private var first: LinkedListElement<T>? = nil
    private var last: LinkedListElement<T>? = nil
    private var count: Int = 0
    
    var isEmpty: Bool {
        return count == 0
    }
    
    func getCount() -> Int {
        return count
    }
    
    func enqueue(elt: T) -> Void {
        
        let linkedElt = LinkedListElement(element: elt)
        
        if self.last == nil {
            self.first = linkedElt
        } else {
            self.last?.next = linkedElt
        }
        
        self.last = linkedElt
        self.count = self.count + 1
    }
    
    func push(elt: T) -> Void {
        self.first = LinkedListElement(element: elt, next: self.first)
        self.last = self.last ?? self.first
        self.count = self.count + 1
    }
    
    func pop() -> T? {
        let top = self.first?.element
        self.first = self.first?.next
        self.count = max(self.count - 1, 0)
        if self.count == 0 {
            self.last = nil
        }
        return top
    }
    
    func peek() -> T? {
        return self.first?.element
    }
    
    func removeWhere(shouldRemove: (T) -> Bool)  {
        let result = self.first?.removeWhere(shouldRemove: shouldRemove)
        self.first = result?.0
        self.last = result?.1
        self.count = result?.2 ?? 0
    }
    
    func asArray() -> [T] {
        return self.first?.toArray() ?? []
    }
    
    func removeAll() -> Void {
        self.first = nil
        self.last = nil
        self.count = 0
    }
}


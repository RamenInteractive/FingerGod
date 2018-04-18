//
//  PriorityQueue.swift
//  FingerGod
//
//  Created by Aaron F on 2018-04-13.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation

class PriorityQueue<T> : NSObject {
    private var heap : [(item: T, priority: Float)] = []
    
    public func compare(_ from: Float, to: Float) -> Bool {
        return from < to
    }
    
    // Simple heap appending algorithm
    public func add(item: T, priority: Float) {
        heap.append((item: item, priority: priority));
        var pos = heap.count - 1
        
        while(pos != 0 && compare(heap[pos].priority, to: heap[(pos - 1) / 2].priority)) {
            let tmp = heap[(pos - 1) / 2]
            heap[(pos - 1) / 2] = heap[pos]
            heap[pos] = tmp
            
            pos = (pos - 1) / 2
        }
    }
    
    // Heap removal algorithm
    public func shift() -> T {
        // Begin by swapping the root with the last element
        let o = heap[0]
        heap[0] = heap[heap.count - 1]
        heap[heap.count - 1] = o
        
        _ = heap.popLast()
        
        // Down-heap
        var pos = 0
        while ((pos * 2 + 1) < heap.count) {
            var childPos = pos * 2 + 1
            if (childPos + 1 < heap.count) {
                // If there are two children, compare them and find position of the one with higher compare value
                childPos = compare(heap[childPos].priority, to: heap[childPos + 1].priority) ? childPos : childPos + 1
            }
            
            // If this item has a higher compare value than its highest valued child, then it's in the correct place
            if (compare(heap[pos].priority, to: heap[childPos].priority)) {
                break
            }
            // Otherwise, we need to swap it with that child
            else {
                let tmp = heap[pos]
                heap[pos] = heap[childPos]
                heap[childPos] = tmp
                
                pos = childPos
            }
        }
        
        return o.item
    }
    
    // Get the priority of the root
    // Returns nil if the heap is empty
    public func getRootPriority() -> Float? {
        if (heap.count != 0) {
            return heap[0].priority
        }
        return nil
    }
    
    // Get the size
    public var count: Int {
        return heap.count
    }
}

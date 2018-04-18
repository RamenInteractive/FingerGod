//
//  FingerGodPriorityQueueTests.swift
//  FingerGodTests
//
//  Created by Aaron F on 2018-04-14.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import XCTest
@testable import FingerGod

class FingerPriorityQueueTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testQueue() {
        let q = PriorityQueue<Int>()
        q.add(item: 6, priority: 1.0)
        q.add(item: 8, priority: 0.2)
        q.add(item: 10, priority: 1.6)
        q.add(item: 20, priority: 20)
        q.add(item: 62, priority: 5)
        q.add(item: -3, priority: -1)
        q.add(item: -7, priority: 7)
        q.add(item: 0, priority: 0)
        
        XCTAssert(q.shift() == -3)
        XCTAssert(q.shift() == 0)
        XCTAssert(q.shift() == 8)
        XCTAssert(q.shift() == 6)
        XCTAssert(q.shift() == 10)
        XCTAssert(q.shift() == 62)
        XCTAssert(q.shift() == -7)
        XCTAssert(q.shift() == 20)
    }
}

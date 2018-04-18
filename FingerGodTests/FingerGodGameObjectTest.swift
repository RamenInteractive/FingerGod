//
//  FingerGodGameObjectTest.swift
//  FingerGodTests
//
//  Created by Aaron F on 2018-02-16.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import XCTest
@testable import FingerGod

class FingerGodGameObjectTest: XCTestCase {
    var game = Game()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testObjectComponentsBasic() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let c1 = GameObject()
        let c2 = GameObject()
        c1.addComponent(type: CounterComponent.self)
        c2.addComponent(type: CounterComponent.self)
        c2.getComponent(type: CounterComponent.self)?.count = 5
        game.addGameObject(gameObject: c1);
        
        game.update();
        XCTAssert(c1.getComponent(type: CounterComponent.self)?.count == 1)
        
        game.addGameObject(gameObject: c2);
        
        game.update();
        XCTAssert(c1.getComponent(type: CounterComponent.self)?.count == 2)
        XCTAssert(c2.getComponent(type: CounterComponent.self)?.count == 6)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

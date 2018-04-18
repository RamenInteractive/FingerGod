//
//  Subscriber.swift
//  FingerGod
//
//  Created by Matt Taylor on 2018-02-19.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation


/// Protocol for subscribers to EventDispatcher events
protocol Subscriber : class {
    
    
    /// # Notify
    /// Function called when an event this object is subscribed to is published
    ///
    /// - Parameters:
    ///   - eventName: name of event that was published
    ///   - params: array of parameters passed to the function
    func notify(_ eventName: String, _ params: [String : Any] )
}

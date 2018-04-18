//
//  EventDispatcher.swift
//  FingerGod
//
//  Created by Matt Taylor on 2018-02-19.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation


/// Static class to coordinate events. Allows objects that follow the Subscriber protocol to
/// subscribe to events. Any object can publish an event.
class EventDispatcher {
    private static var _eventList = [String : [Subscriber]]()
    
    public static func clearAll() {
        _eventList = [String : [Subscriber]]()
    }
    
    
    /// # Subscribe
    /// Subscribes an object passed into the function to the given event
    ///
    /// - Parameters:
    ///   - eventName: name of event to subscribe to
    ///   - subscriber: object to subscribe to the event
    /// - Returns: true if object was successfully subscribed to the given event
    @discardableResult
    public static func subscribe(_ eventName : String, _ subscriber : Subscriber) -> Bool {
        if (_eventList[eventName] == nil) {
            _eventList[eventName] = [Subscriber]()
        }
        if (!_eventList[eventName]!.contains(where: {$0 === subscriber})) {
            _eventList[eventName]!.append(subscriber)
            return true
        }
        return false
    }
    
    
    /// # Unsubscribe
    /// Unsubscribes an object passed into the function from a given event
    ///
    /// - Parameters:
    ///   - eventName: name of event to unsubscribe from
    ///   - subscriber: object to unsubscribe
    /// - Returns: true if object was successfully unsubscribed from the given event
    @discardableResult
    public static func unsubscribe(_ eventName: String, _ subscriber : Subscriber) -> Bool {
        if (_eventList[eventName] != nil) {
            if let index = _eventList[eventName]!.index(where: {$0 === subscriber}) {
                _eventList[eventName]!.remove(at: index)
                return true
            }
        }
        return false
    }
    
    
    /// # Publish
    /// Publish an event and notify all subscribers of that event
    ///
    /// - Parameters:
    ///   - eventName: name of event to publish
    ///   - params: dictionary of parameters to pass to subscribers
    /// - Returns: true if subscribers to the given event were notified
    @discardableResult
    public static func publish(_ eventName: String, _ params: [String : Any]) -> Bool {
        if let subscriberList = _eventList[eventName] {
            for subscriber in subscriberList {
                subscriber.notify(eventName, params)
            }
            return true
        }
        return false
    }
    
    
    /// # Publish
    /// Publish an event and notify all subscribers of that event
    ///
    /// - Parameters:
    ///   - eventName: name of event to publish
    ///   - param: parameters to pass to subscribers
    /// - Returns: true if subscribers to the given event were notified
    @discardableResult
    public static func publish(_ eventName: String, _ param: (String, Any)...) -> Bool {
        var paramList = [String:Any]()
        for (key,value) in param {
            paramList[key] = value
        }
        return publish(eventName, paramList)
    }
}

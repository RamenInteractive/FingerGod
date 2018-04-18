//
//  Image.swift
//  FingerGod
//
//  Created by Aaron Freytag on 2018-04-17.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import GLKit

public class Image {
    public var img : CGImage
    public var name : String
    public init(_ name : String, _ img : CGImage) {
        self.img = img
        self.name = name
    }
}

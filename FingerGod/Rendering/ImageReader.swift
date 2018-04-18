//
//  ImageReader.swift
//  FingerGod
//
//  Created by Aaron Freytag on 2018-04-17.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import GLKit

public class ImageReader {
    public static func read(name : String) -> Image {
        let img = UIImage(named: name)?.cgImage
        return Image(name, img!)
    }
}

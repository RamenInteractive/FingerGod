  //
//  RoundButton.swift
//  FingerGod
//
//  Created by Niko Lauron on 2018-03-26.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import UIKit
@IBDesignable
  
public class RoundButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius;
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth;
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor;
        }
    }
}

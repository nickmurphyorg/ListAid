//
//  TextFieldUnderline.swift
//  Listaid
//
//  Created by Nick Murphy on 2/17/19.
//  Copyright © 2019 Nick Murphy. All rights reserved.
//

import UIKit

extension UIView {
    
    func createUnderline(color: UIColor) -> CALayer {
        let underline = CALayer()
        underline.backgroundColor = color.cgColor
        underline.frame = CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 1)
        
        return underline
    }
    
}

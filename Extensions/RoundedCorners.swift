//
//  RoundedCorners.swift
//  Listaid
//
//  Created by Nick Murphy on 9/30/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

extension UIView {
    
    func roundedCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        let roundedPath = CAShapeLayer()
        roundedPath.path = path.cgPath
        
        self.layer.mask = roundedPath
    }
    
}

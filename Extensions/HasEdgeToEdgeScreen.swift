//
//  EdgeToEdgeScreen.swift
//  Listaid
//
//  Created by Nick Murphy on 3/22/19.
//  Copyright © 2019 Nick Murphy. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func hasEdgeToEdgeScreen() -> Bool {
        // Detect if the device has a physical home button
        if #available(iOS 11.0, *), let window = UIApplication.shared.keyWindow {
            return window.safeAreaInsets.bottom > 0 ? true : false
        }
        
        return false
    }
}

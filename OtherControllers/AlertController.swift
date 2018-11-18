//
//  AlertController.swift
//  Listaid
//
//  Created by Nick Murphy on 11/17/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

struct Alert {
    static func newAlert(title: String, message: String, hasCancel: Bool, buttonLabel: String, buttonStyle: UIAlertAction.Style, completion: ((UIAlertAction) -> Void)? ) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let acceptButton = UIAlertAction(title: buttonLabel, style: buttonStyle, handler: completion)
        
        if hasCancel {
            alertController.addAction(cancelButton)
        }
        alertController.addAction(acceptButton)
        
        return alertController
    }
}

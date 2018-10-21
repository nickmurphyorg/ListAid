//
//  SettingsViewController.swift
//  Listaid
//
//  Created by Nick Murphy on 9/30/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var settingsNavigationBar: UINavigationBar!
    @IBOutlet weak var settingsBackground: UIView!
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyling()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBAction func dismissSettings(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension SettingsViewController {
    func applyStyling() {
        //settingsTableView.insetsContentViewsToSafeArea = true
        // Causing rendering issues on larger devices.
        //settingsNavigationBar.roundedCorners(corners: [.topLeft, .topRight], radius: 4)
        //settingsBackground.roundedCorners(corners: [.topLeft, .topRight], radius: 4)
    }
}

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
    
    private let listStyleMetrics = ListStyleMetric()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTableView.contentInset.top = settingsNavigationBar.bounds.height
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        settingsBackground.roundedCorners(corners: [.topLeft, .topRight], radius: listStyleMetrics.cornerRadius)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBAction func dismissSettings(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

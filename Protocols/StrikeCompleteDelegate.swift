//
//  StrikeCompleteDelegate.swift
//  Listaid
//
//  Created by Nick Murphy on 1/6/19.
//  Copyright © 2019 Nick Murphy. All rights reserved.
//

import Foundation
import UIKit

protocol StrikeCompleteDelegate: class where Self: UIViewController {
    func completeItem(tableViewCell: UITableViewCell)
}

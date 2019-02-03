//
//  ReorderListDelegate.swift
//  Listaid
//
//  Created by Nick Murphy on 2/2/19.
//  Copyright © 2019 Nick Murphy. All rights reserved.
//

import Foundation

protocol ReorderListDelegate {
    func moveItem(at: Int, to: Int)
}

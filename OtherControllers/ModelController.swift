//
//  ModelController.swift
//  Listaid
//
//  Created by Nick Murphy on 9/30/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import Foundation

class ModelController {
    static let shared = ModelController()
    
    private let list1 = List(name: "Grocery", items: [
            Item(name: "Milk", listed: false, completed: false ),
            Item(name: "Bread", listed: false, completed: false),
            Item(name: "Granola", listed: false, completed: false)
        ])
    
    private let list2 = List(name: "Target", items: [
            Item(name: "Papertowel", listed: false, completed: false),
            Item(name: "Razor", listed: false, completed: false)
        ])
    
    private var lists: [List]
    
    init() {
        lists = [list1, list2]
    }
    
    func fetchLists() -> [List] {
        return lists
    }
}

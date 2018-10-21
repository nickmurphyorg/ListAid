//
//  UserPreferencesController.swift
//  Listaid
//
//  Created by Nick Murphy on 10/14/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import Foundation

class UserPreferences {
    static let shared = UserPreferences()
    
    let preferences = UserDefaults.standard
    let listIndex = "listIndex"
    
    private var selectedListIndex: Int
    
    private init() {
        selectedListIndex = preferences.integer(forKey: listIndex)
    }
    
    func returnSavedListIndex() -> Int {
        return selectedListIndex
    }
    
    func saveSelectedList(index: Int) {
        preferences.set(index, forKey: listIndex)
        selectedListIndex = index
    }
}

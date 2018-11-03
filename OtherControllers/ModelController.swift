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
            Item(name: "Milk", listed: true, completed: true ),
            Item(name: "Bread", listed: true, completed: false),
            Item(name: "Granola", listed: false, completed: false)
        ])
    
    private let list2 = List(name: "Target", items: [
            Item(name: "Papertowel", listed: true, completed: true),
            Item(name: "Razor", listed: false, completed: false)
        ])
    
    private var lists: [List]
    
    init() {
        lists = [list1, list2]
    }
    
    func returnAllLists() -> [List] {
        var filteredLists: [List] = []
        
        for list in lists {
            let filteredItems = list.items.filter { $0.listed == true }
            
            filteredLists.append(List(name: list.name, items: filteredItems))
        }
        
        return filteredLists
    }
    
    func returnFilteredList(atIndex: Int) -> List? {
        guard lists.indices.contains(atIndex) else { return nil }
        
        let savedList = lists[atIndex]
        let listedItems = savedList.items.filter { $0.listed == true }
        
        return List(name: savedList.name, items: listedItems)
    }
    
    func returnAllItemsInList(atIndex: Int) -> [Item]? {
        guard lists.indices.contains(atIndex) else { return nil }
        
        return lists[atIndex].items
    }
    
    /*
    func returnListedItemsInList(atIndex: Int) -> [Item]? {
        guard lists.indices.contains(atIndex) else { return nil }
    }
    */
    
    func updateListItems(atIndex: Int, listItems: [Item]) {
        guard lists.indices.contains(atIndex) else { return }
        
        lists[atIndex].items = listItems
    }
    
    func updateListName(listIndex: Int, newName: String) {
        // Add error alert if name cannot be updated.
        guard lists.indices.contains(listIndex) else { return }
        
        lists[listIndex].name = newName
    }
    
    func addNewList(newList: List) -> [List] {
        lists.append(newList)
        
        return returnAllLists()
    }
    
    func deleteList(listIndex: Int) -> [List] {
        guard lists.indices.contains(listIndex) else { return lists }
        
        lists.remove(at: listIndex)
        
        return returnAllLists()
    }
}

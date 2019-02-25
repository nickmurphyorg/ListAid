//
//  ModelController.swift
//  Listaid
//
//  Created by Nick Murphy on 9/30/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ModelController {
    static let shared = ModelController()
    
    private let listObject = "ListObject"
    private let itemObject = "ItemObject"
    private let listNameKey = "name"
    
    private var managedContext: NSManagedObjectContext? = nil
    private var lists = [List]()
    
    // TODO: Will need to setup a serial queue to perform operations on the objects...
    
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        managedContext = appDelegate.persistentContainer.viewContext
        
        guard managedContext != nil else { return }
        
        let savedList = NSFetchRequest<NSManagedObject>(entityName: listObject)
        
        do {
            let savedLists: [NSManagedObject] = try managedContext!.fetch(savedList)
            
            print("CoreData returned \(savedLists.count) lists.")
            
            for list in savedLists {
                let listInstance = List.init(drinkEntity: list)
                
                lists.append(listInstance)
            }
            
            // Sort the lists by index if available.
            let sortedLists = lists.sorted { (firstList, secondList) -> Bool in
                guard firstList.index != nil && secondList.index != nil else { return false }
                
                return firstList.index! < secondList.index!
            }
            
            // Set the index for lists that dont have an index (v1 - v2 conversion)
            for (index, var list) in sortedLists.enumerated() {
                if list.index != index {
                    list.index = index
                    
                    // Call this method on a background thread...
                    saveListIndex(index)
                }
            }
            
            lists = sortedLists
            
        } catch let error as NSError {
            print("CoreData could not retrieve lists: \(error) \n \(error.userInfo)")
        }
    }
    
    func returnAllLists() -> [List] {
        var filteredLists: [List] = []
        
        for list in lists {
            var listObject = list
            listObject.items = list.items.filter { $0.listed == true }
            
            filteredLists.append(listObject)
        }
        
        return filteredLists
    }
    
    func returnFilteredList(atIndex: Int) -> List? {
        guard lists.indices.contains(atIndex) else { return nil }
        
        var savedList = lists[atIndex]
        savedList.items = savedList.items.filter { $0.listed == true }
        // Sort items by index...
        
        return savedList
    }
    
    func returnSavedListName(listIndex: Int) -> String? {
        guard lists.indices.contains(listIndex) else { return nil }
        
        return lists[listIndex].name
    }
    
    func addNewList() -> [List] {
        guard managedContext != nil else { return returnAllLists() }
        
        let coreDataEntity = NSEntityDescription.entity(forEntityName: listObject, in: managedContext!)
        let newListEntity = NSManagedObject(entity: coreDataEntity!, insertInto: managedContext!) as! ListObject
        newListEntity.index = Int16(lists.count)
        
        do {
            try managedContext?.save()
            
            lists.append(List(drinkEntity: newListEntity))
            
            print("New list was saved.")
        } catch let error as NSError {
            print("Could not save new list.\nError: \(error)")
        }
        
        return returnAllLists()
    }
    
    func updateListName(listIndex: Int, newName: String) {
        guard managedContext != nil && lists.indices.contains(listIndex) else { return }
        
        let listToRename = managedContext!.object(with: lists[listIndex].id) as! ListObject
        listToRename.name = newName
        
        do {
            try managedContext?.save()
            
            lists[listIndex].name = newName
            
            print("List was renamed to: \(newName).")
        } catch let error as NSError {
            print("List could not be renamed to: \(newName). Error: \(error)")
        }
    }
    
    func deleteList(listIndex: Int) -> [List] {
        guard managedContext != nil && lists.indices.contains(listIndex) else { return returnAllLists() }
        
        let listToDelete = managedContext!.object(with: lists[listIndex].id)
        
        managedContext?.delete(listToDelete)
        
        do {
            try managedContext?.save()
            
            lists.remove(at: listIndex)
            
            for index in listIndex..<lists.count {
                lists[index].index = index
                
                //Perform on background thread
                saveListIndex(index)
            }
            
            print("List was deleted.")
        } catch let error as NSError {
            print("Could not delete list \(lists[listIndex].name). Error: \(error)")
        }
        
        return returnAllLists()
    }
    
    func reorderList(_ from: Int, _ to: Int) -> [List] {
        lists.swapAt(from, to)
        lists[from].index = to
        lists[to].index = from
        
        // On a background thread in the dispatch queue...
        saveListIndex(from)
        saveListIndex(to)
        
        return returnAllLists()
    }
    
    func saveListIndex(_ index: Int) {
        guard managedContext != nil && lists.indices.contains(index) else { return }
        
        let list = managedContext!.object(with: lists[index].id) as! ListObject
        list.index = Int16(index)
        
        do {
            try managedContext?.save()
        } catch let error as NSError {
            print("Could not update index for \(lists[index].name): \(error)")
        }
    }
    
    func returnAllItemsInList(atIndex: Int) -> [Item]? {
        guard lists.indices.contains(atIndex) else { return nil }
        
        return lists[atIndex].items
    }
    
    func returnFilteredItemsInList(atIndex: Int) -> [Item]? {
        guard lists.indices.contains(atIndex) else { return nil }
        
        let filteredItemList = lists[atIndex].items.filter { $0.listed == true }
        // sort the list by index...
        return filteredItemList
    }
    
    func addItemToList(listIndex: Int, itemName: String) -> [Item]? {
        guard managedContext != nil && lists.indices.contains(listIndex) else { return returnAllItemsInList(atIndex: listIndex) }
        
        let listEntity = managedContext!.object(with: lists[listIndex].id) as! ListObject
        let itemEntity = NSEntityDescription.insertNewObject(forEntityName: itemObject, into: managedContext!) as! ItemObject
        
        itemEntity.name = itemName
        itemEntity.completed = false
        // .index: int? = nil
        itemEntity.listed = false
        itemEntity.list = listEntity
        
        listEntity.addToItems(itemEntity)
        
        do {
            try managedContext?.save()
            
            lists[listIndex].items.append(Item.init(itemEntity: itemEntity))
            
            print("\(itemName) was added to list.")
        } catch let error as NSError {
            print("\(itemName) could not be added. Error: \(error)")
        }
        
        return returnAllItemsInList(atIndex: listIndex)
    }
    
    func deleteItemInList(listIndex: Int, itemIndex: Int) -> [Item]? {
        guard managedContext != nil &&
            lists.indices.contains(listIndex) &&
            lists[listIndex].items.indices.contains(itemIndex)
        else {
            return returnAllItemsInList(atIndex: listIndex)
        }
        
        let itemToDelete = managedContext!.object(with: lists[listIndex].items[itemIndex].id)
        
        managedContext!.delete(itemToDelete)
        
        do {
            try managedContext?.save()
            
            lists[listIndex].items.remove(at: itemIndex)
            // Update index property for all items after if index != nil
            print("Item was deleted.")
        } catch let error as NSError {
            print("Item could not be deleted. Error: \(error)")
        }
        
        return returnAllItemsInList(atIndex: listIndex)
    }
    
    func renameItemInList(listIndex: Int, itemIndex: Int, newName: String) -> [Item]? {
        guard managedContext != nil &&
            lists.indices.contains(itemIndex) &&
            lists[listIndex].items.indices.contains(itemIndex)
        else {
            return returnAllItemsInList(atIndex: listIndex)
        }
        
        let itemToRename = managedContext!.object(with: lists[listIndex].items[itemIndex].id) as! ItemObject
        itemToRename.name = newName
        
        do {
            try managedContext!.save()
            
            lists[listIndex].items[itemIndex].name = newName
            
            print("Item was renamed: \(newName)")
        } catch let error as NSError {
            print("Could not rename item to \(newName). Error: \(error)")
        }
        
        return returnAllItemsInList(atIndex: listIndex)
    }
    
    func toggleItemListStatus(listIndex: Int, itemID: NSManagedObjectID) {
        guard managedContext != nil && lists.indices.contains(listIndex) else { return }
        
        let itemEntity = managedContext!.object(with: itemID) as! ItemObject
        // .index = listed ? int : nil
        itemEntity.listed.toggle()
        itemEntity.completed = false
        
        do {
            try managedContext?.save()
            
            for (index, item) in lists[listIndex].items.enumerated() {
                if item.id === itemID {
                    // if item listed drop decrement index of following items...
                    lists[listIndex].items[index].listed.toggle()
                    
                    // if item not listed return list count and set index...
                    break
                }
            }
            
            print("\(itemEntity.name ?? "Item") was toggled.")
        } catch let error as NSError {
            print("Item listed could not be toggled. Error: \(error)")
        }
    }
    
    func toggleItemCompletionStatus(listIndex: Int, itemID: NSManagedObjectID) {
        guard managedContext != nil && lists.indices.contains(listIndex) else { return }
        
        let itemToToggle = managedContext!.object(with: itemID) as! ItemObject
        itemToToggle.completed.toggle()
        
        do {
            try managedContext?.save()
            
            for (index, item) in lists[listIndex].items.enumerated() {
                if item.id === itemID {
                    lists[listIndex].items[index].completed.toggle()
                    
                    break
                }
            }
            
            print("\(itemToToggle.name ?? "Item") completion was toggled.")
        } catch let error as NSError {
            print("Item completion could not be toggled. Error: \(error)")
        }
    }
    
    func reorderItemInList(listIndex: Int, _ fromIndex: Int, _ toIndex: Int) -> [Item]? {
        // This will be refactored when persistent ordering is built...
        var listItems: [Item]?
        
        if var items = returnFilteredItemsInList(atIndex: listIndex) {
            items.swapAt(fromIndex, toIndex)
            // save index on background thread...
            listItems = items
        }
        
        return listItems
    }
    
    func purgeCompletedItems(listIndex: Int) -> List? {
        guard managedContext != nil && lists.indices.contains(listIndex) else { return nil }
        
        var editedItemIndicies = [Int]()
        
        for (index, item) in lists[listIndex].items.enumerated() {
            if item.completed && item.listed {
                let itemToPurge = managedContext!.object(with: item.id) as! ItemObject
                itemToPurge.completed.toggle()
                // .index = nil
                itemToPurge.listed.toggle()
                
                editedItemIndicies.append(index)
            }
        }
        
        do {
            try managedContext?.save()
            
            for index in editedItemIndicies {
                lists[listIndex].items[index].completed.toggle()
                // null index property...
                lists[listIndex].items[index].listed.toggle()
            }
            
            print("\(lists[listIndex].name) has been purged.")
        } catch let error as NSError {
            print("Could not purge list: \(error)")
        }
        
        return returnFilteredList(atIndex: listIndex)
    }
}

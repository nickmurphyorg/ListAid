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
    private let saveQueue = DispatchQueue(label: "org.nickmurphy.ListAid.saveQueue", qos: .default)
    
    private var managedContext: NSManagedObjectContext? = nil
    
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    func returnAllLists() -> [List] {
        guard managedContext != nil else { return [] }
        
        let savedList = NSFetchRequest<NSManagedObject>(entityName: listObject)
        
        var lists = [List]()
        
        do {
            let savedLists: [NSManagedObject] = try managedContext!.fetch(savedList)
            
            print("CoreData returned \(savedLists.count) lists.")
            
            for list in savedLists {
                let listInstance = List.init(listEntity: list)
                
                lists.append(listInstance)
            }
            
            // Sort the lists by index if available.
            let sortedLists = lists.sorted { (firstList, secondList) -> Bool in
                guard firstList.index != nil && secondList.index != nil else { return false }
                
                return firstList.index! < secondList.index!
            }
            
            lists = sortedLists
            
        } catch let error as NSError {
            print("CoreData could not retrieve lists: \(error) \n \(error.userInfo)")
        }
        
        return lists
    }
    
    func returnSavedListName(listId: NSManagedObjectID) -> String? {
        guard managedContext != nil else { return nil }
        
        let listEntity = managedContext?.object(with: listId) as! ListObject
        
        return listEntity.name
    }
    
    func addNewList() -> [List] {
        var savedLists = returnAllLists()
        
        guard managedContext != nil else { return savedLists }
        
        let coreDataEntity = NSEntityDescription.entity(forEntityName: listObject, in: managedContext!)
        let newListEntity = NSManagedObject(entity: coreDataEntity!, insertInto: managedContext!) as! ListObject
        newListEntity.index = Int16(savedLists.count)
        
        do {
            try managedContext?.save()
            
            savedLists.append(List(listEntity: newListEntity))
            
            print("New list was saved.")
        } catch let error as NSError {
            print("Could not save new list.\nError: \(error)")
        }
        
        return savedLists
    }
    
    func updateListName(listId: NSManagedObjectID, newName: String) {
        guard managedContext != nil else { return }
        
        let listToRename = managedContext!.object(with: listId) as! ListObject
        listToRename.name = newName
        
        saveQueue.async { [weak self] in
            guard let weakSelf = self else { return }
            
            do {
                try weakSelf.managedContext?.save()
                
                print("List was renamed to: \(newName).")
            } catch let error as NSError {
                print("List could not be renamed to: \(newName). Error: \(error)")
            }
        }
    }
    
    func deleteList(listId: NSManagedObjectID) -> [List] {
        guard managedContext != nil else { return returnAllLists() }
        
        var updatedLists = [List]()
        
        let listToDelete = managedContext!.object(with: listId) as! ListObject
        
        managedContext?.delete(listToDelete)
        
        do {
            try managedContext?.save()
            
            updatedLists = returnAllLists()
            
            for (index, list) in updatedLists.enumerated() {
                if list.index != index {
                    updatedLists[index].index = index
                    
                    saveListIndex(index, for: list.id)
                }
            }
            
            print("List was deleted.")
        } catch let error as NSError {
            print("Could not delete list. Error: \(error)")
        }
        
        return updatedLists
    }
    
    func reorder(lists: [List], _ fromIndex: Int, _ toIndex: Int) -> [List] {
        var savedLists = lists
        
        savedLists.swapAt(fromIndex, toIndex)
        savedLists[fromIndex].index = toIndex
        savedLists[toIndex].index = fromIndex
        
        saveListIndex(fromIndex, for: savedLists[fromIndex].id)
        saveListIndex(toIndex, for: savedLists[toIndex].id)
        
        return savedLists
    }
    
    func saveListIndex(_ index: Int, for listId: NSManagedObjectID) {
        guard managedContext != nil else { return }
        
        let list = managedContext!.object(with: listId) as! ListObject
        list.index = Int16(index)
        
        saveQueue.async { [weak self] in
            guard let weakSelf = self else { return }
            
            do {
                try weakSelf.managedContext?.save()
            } catch let error as NSError {
                print("Could not update list index: \(error)")
            }
        }
    }
    
    func returnAllItemsInList(_ listId: NSManagedObjectID) -> [Item] {
        guard managedContext != nil else { return [] }
        
        var listItems = [Item]()
        
        let list = managedContext!.object(with: listId) as! ListObject
        
        if let savedItems = list.items {
            for item in savedItems {
                listItems.append(Item.init(itemEntity: item as! NSManagedObject))
            }
        }
        
        return listItems
    }
    
    func returnFilteredItemsInList(listId: NSManagedObjectID) -> [Item] {
        guard managedContext != nil else { return [] }
        
        var listItems = [Item]()
        
        let list = managedContext!.object(with: listId) as! ListObject
        
        if list.items != nil {
            let filterPredicate = NSPredicate(format: "listed == true")
            let listedItems = Array(list.items!.filtered(using: filterPredicate))
            
            for item in listedItems {
                listItems.append(Item.init(itemEntity: item as! NSManagedObject))
            }
            
            listItems = sortItemsByIndex(listItems)
        }
        
        return listItems
    }
    
    func addItemToList(listId: NSManagedObjectID, itemName: String) -> [Item]? {
        guard managedContext != nil else { return returnAllItemsInList(listId) }
        
        let listEntity = managedContext!.object(with: listId) as! ListObject
        let itemEntity = NSEntityDescription.insertNewObject(forEntityName: itemObject, into: managedContext!) as! ItemObject
        
        itemEntity.name = itemName
        itemEntity.completed = false
        itemEntity.listed = false
        itemEntity.list = listEntity
        
        listEntity.addToItems(itemEntity)
        
        do {
            try managedContext?.save()
            
            print("\(itemName) was added to list.")
        } catch let error as NSError {
            print("\(itemName) could not be added. Error: \(error)")
        }
        
        return returnAllItemsInList(listId)
    }
    
    func deleteItem(_ index: Int, in items: [Item]) -> [Item] {
        guard managedContext != nil && items.indices.contains(index) else {
            return items
        }
        
        var listItems = items
        
        let itemToDelete = managedContext!.object(with: listItems[index].id)
        
        managedContext!.delete(itemToDelete)
        
        do {
            try managedContext?.save()
            
            listItems.remove(at: index)

            print("Item was deleted.")
        } catch let error as NSError {
            print("Item could not be deleted. Error: \(error)")
        }
        
        return listItems
    }
    
    func renameItem(_ index: Int, in items: [Item], to newName: String) -> [Item] {
        guard managedContext != nil && items.indices.contains(index) else { return items }
        
        var listItems = items
        
        let itemToRename = managedContext!.object(with: items[index].id) as! ItemObject
        itemToRename.name = newName
        
        do {
            try managedContext!.save()
            
            listItems[index].name = newName
            
            print("Item was renamed: \(newName)")
        } catch let error as NSError {
            print("Could not rename item to \(newName). Error: \(error)")
        }
        
        return listItems
    }
    
    func toggleListStatus(itemID: NSManagedObjectID) {
        guard managedContext != nil else { return }
        
        let itemEntity = managedContext!.object(with: itemID) as! ItemObject
        itemEntity.listed.toggle()
        itemEntity.completed = false
        
        do {
            try managedContext?.save()
            
            print("\(itemEntity.name ?? "Item") was toggled.")
        } catch let error as NSError {
            print("Item listed could not be toggled. Error: \(error)")
        }
    }
    
    func toggleCompletionStatus(itemID: NSManagedObjectID) {
        guard managedContext != nil else { return }
        
        let itemToToggle = managedContext!.object(with: itemID) as! ItemObject
        itemToToggle.completed.toggle()
        
        saveQueue.async { [weak self] in
            guard let weakSelf = self else { return }
            
            do {
                try weakSelf.managedContext?.save()
                
                print("\(itemToToggle.name ?? "Item") completion was toggled.")
            } catch let error as NSError {
                print("Item completion could not be toggled. Error: \(error)")
            }
        }
    }
    
    //might make an extension...
    func reorder(items: [Item], _ fromIndex: Int, _ toIndex: Int) -> [Item] {
        var listItems = items
        
        listItems.swapAt(fromIndex, toIndex)
        listItems[toIndex].index = toIndex
        listItems[fromIndex].index = fromIndex
        
        saveItem(listItems[toIndex].id, index: toIndex)
        saveItem(listItems[fromIndex].id, index: fromIndex)
        
        return listItems
    }
    
    func returnSortedItemsInList(_ listId: NSManagedObjectID) -> [Item] {
        guard managedContext != nil else { return [] }
        
        var listItems = [Item]()
        
        let list = managedContext!.object(with: listId) as! ListObject
        
        if list.items != nil {
            let filterPredicate = NSPredicate(format: "listed == true")
            let listedItems = Array(list.items!.filtered(using: filterPredicate))
            
            for item in listedItems {
                listItems.append(Item.init(itemEntity: item as! NSManagedObject))
            }
            
            // Update Items With An Accurate Index
            for (index, item) in listItems.enumerated() {
                if item.index ?? nil != index {
                    listItems[index].index = index
                    
                    saveItem(item.id, index: index)
                }
            }
        }
        
        return listItems
    }
    
    func purgeCompleted(items: [Item]) -> [Item] {
        guard managedContext != nil else { return items }
        
        var listItems = items
        
        // Update completed items in core data
        for item in listItems {
            if item.completed {
                let itemToPurge = managedContext!.object(with: item.id) as! ItemObject
                itemToPurge.completed.toggle()
                itemToPurge.index = -1
                itemToPurge.listed.toggle()
            }
        }
        
        // Remove completed items
        listItems = listItems.filter { $0.completed == false }
        
        do {
            try managedContext?.save()
            
            // Save the updated item index to core data
            for (index, item) in listItems.enumerated() {
                if item.index ?? nil != index {
                    listItems[index].index = index
                    
                    saveItem(item.id, index: index)
                }
            }
            
            print("List has been purged.")
        } catch let error as NSError {
            print("Could not purge list: \(error)")
        }
        
        return listItems
    }
}

//MARK: - Helper Methods
extension ModelController {
    func sortItemsByIndex(_ items: [Item]) -> [Item] {
        let sortedItems = items.sorted { (firstItem, secondItem) -> Bool in
            guard firstItem.index != nil && secondItem.index != nil else {
                if firstItem.index != nil && secondItem.index == nil {
                    return true
                } else if firstItem.index == nil && secondItem.index != nil {
                    return false
                }
                
                return false
            }
            
            return firstItem.index! < secondItem.index!
        }
        
        return sortedItems
    }
    
    private func saveItem(_ itemID: NSManagedObjectID, index: Int) {
        guard managedContext != nil else { return }
        
        let itemToUpdate = managedContext?.object(with: itemID) as! ItemObject
        itemToUpdate.index = Int16(index)
        
        do {
            try managedContext?.save()
        } catch let error as NSError {
            print("There was a problem updating the item's index: \(error)")
        }
    }
}

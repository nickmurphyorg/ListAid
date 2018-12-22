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
    let listObject = "ListObject"
    let itemObject = "ItemObject"
    let listNameKey = "name"
    
    private var managedContext: NSManagedObjectContext? = nil
    private var lists: [List] = []
    
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
        } catch let error as NSError {
            print("CoreData could not retrieve lists: \(error) \n \(error.userInfo)")
        }
    }
    
    func returnAllLists() -> [List] {
        var filteredLists: [List] = []
        
        for list in lists {
            let filteredItems = list.items.filter { $0.listed == true }
            
            filteredLists.append(List(id: list.id, name: list.name, items: filteredItems))
        }
        
        return filteredLists
    }
    
    func returnFilteredList(atIndex: Int) -> List? {
        guard lists.indices.contains(atIndex) else { return nil }
        
        let savedList = lists[atIndex]
        let listedItems = savedList.items.filter { $0.listed == true }
        
        return List(id: savedList.id, name: savedList.name, items: listedItems)
    }
    
    func returnSavedListName(listIndex: Int) -> String? {
        guard lists.indices.contains(listIndex) else { return nil }
        
        return lists[listIndex].name
    }
    
    func addNewList() -> [List] {
        guard managedContext != nil else { return returnAllLists() }
        
        let coreDataEntity = NSEntityDescription.entity(forEntityName: listObject, in: managedContext!)
        let newListEntity = NSManagedObject(entity: coreDataEntity!, insertInto: managedContext!)
        
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
        
        let listToRename = managedContext!.object(with: lists[listIndex].id)
        
        listToRename.setValue(newName, forKey: listNameKey)
        
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
        } catch let error as NSError {
            print("Could not delete list \(lists[listIndex].name). Error: \(error)")
        }
        
        return returnAllLists()
    }
    
    func returnAllItemsInList(atIndex: Int) -> [Item]? {
        guard lists.indices.contains(atIndex) else { return nil }
        
        return lists[atIndex].items
    }
    
    func returnFilteredItemsInList(atIndex: Int) -> [Item]? {
        guard lists.indices.contains(atIndex) else { return nil }
        
        let filteredItemList = lists[atIndex].items.filter { $0.listed == true }
        
        return filteredItemList
    }
    
    func addItemToList(listIndex: Int, itemName: String) -> [Item]? {
        guard managedContext != nil && lists.indices.contains(listIndex) else { return returnAllItemsInList(atIndex: listIndex) }
        
        let listEntity = managedContext!.object(with: lists[listIndex].id) as! ListObject
        let itemEntity = NSEntityDescription.insertNewObject(forEntityName: itemObject, into: managedContext!) as! ItemObject
        
        itemEntity.name = itemName
        itemEntity.completed = false
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
    
    func toggleItemListStatus(listIndex: Int, itemIndex: Int) {
        guard managedContext != nil &&
            lists.indices.contains(listIndex) &&
            lists[listIndex].items.indices.contains(itemIndex)
        else {
            return
        }
        
        let itemEntity = managedContext!.object(with: lists[listIndex].items[itemIndex].id) as! ItemObject
        itemEntity.listed.toggle()
        
        do {
            try managedContext?.save()
            
            lists[listIndex].items[itemIndex].listed.toggle()
            
            print("Item was toggled.")
        } catch let error as NSError {
            print("Item could not be toggled. Error: \(error)")
        }
    }
    
    func toggleItemCompletionStatus(listIndex: Int, itemIndex: Int) {
        guard managedContext != nil &&
            lists.indices.contains(listIndex) &&
            lists[listIndex].items.indices.contains(itemIndex)
        else {
            return
        }
        
        let itemToToggle = managedContext!.object(with: lists[listIndex].items[itemIndex].id) as! ItemObject
        itemToToggle.completed.toggle()
        
        do {
            try managedContext?.save()
            
            lists[listIndex].items[itemIndex].completed.toggle()
            
            print("Item completion was toggled.")
        } catch let error as NSError {
            print("Item completion could not be toggled. Error: \(error)")
        }
    }
}

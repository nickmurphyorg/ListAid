//
//  ModelControllerTests.swift
//  ModelControllerTests
//
//  Created by Nick Murphy on 9/30/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import XCTest
import CoreData
@testable import Listaid

class ModelControllerTests: XCTestCase {

    var testListId: NSManagedObjectID!
    var testLists: [List]!
    var testItemList: [Item]!
    
    let testRenameString = "Testing123"
    let testItemName = "TestItem"
    let testItemRename = "TestItemRename"
    
    override func setUp() {
        testLists = ModelController.shared.addNewList()
        
        if let newList = testLists.last {
            testListId = newList.id
        } else {
            fatalError("List ID could not be returned.")
        }
        
        testItemList = ModelController.shared.addItemToList(listId: testListId, itemName: testItemName)
        testItemList = ModelController.shared.addItemToList(listId: testListId, itemName: testItemRename)
    }

    override func tearDown() {
        _ = ModelController.shared.deleteList(listId: testListId)
        testListId = nil
        testLists = nil
        testItemList = nil
    }

    func testAddNewList() {
        let currentListCount = testLists.count
        
        testLists = ModelController.shared.addNewList()

        XCTAssertEqual(testLists.count, currentListCount + 1)
    }
    
    func testUpdateListName() {
        ModelController.shared.updateListName(listId: testListId, newName: testRenameString)
        
        let savedName = ModelController.shared.returnSavedListName(listId: testListId)
        
        XCTAssertEqual(savedName, testRenameString)
    }
    
    func testReturnSavedListName() {
        ModelController.shared.updateListName(listId: testListId, newName: testRenameString)
        
        let savedListName = ModelController.shared.returnSavedListName(listId: testListId)
        
        XCTAssertTrue(savedListName == testRenameString)
    }
    
    func testAddItemToList() {
        let itemsInList = ModelController.shared.addItemToList(listId: testListId, itemName: testItemName)
        
        if let itemsInList = itemsInList {
            XCTAssertTrue(testItemList.count < itemsInList.count)
        } else {
            XCTFail("Item was not added to list.")
        }
    }
    
    func testSaveListIndex() {
        let listIndex = testLists.count - 1
        
        ModelController.shared.saveListIndex(listIndex, for: testListId)
        
        let updatedLists = ModelController.shared.returnAllLists()
        
        if let testList = updatedLists.last {
            XCTAssertTrue(testList.index == listIndex)
        } else {
            XCTFail("Test list could not be returned")
        }
        
    }
    
    func testReturnAllItemsInList() {
        let itemsInList = ModelController.shared.returnAllItemsInList(testListId)
        
        XCTAssertTrue(itemsInList.count == testItemList.count)
    }
    
    func testReturnFilteredItemsInList() {
        let filteredList = ModelController.shared.returnFilteredItemsInList(listId: testListId)
        let sansListed = filteredList.filter { $0.listed == true }
            
        XCTAssertTrue(sansListed.count == 0)
    }
    
    func testRenameItemInList() {
        let updatedItemList = ModelController.shared.renameItem(0, in: testItemList, to: testItemRename)
        let renamedItem = updatedItemList.first
        
        if let renamedItem = renamedItem {
            XCTAssertEqual(renamedItem.name, testItemRename)
        } else {
            XCTFail("Renamed item could not be unwrapped.")
        }
    }
    
    func testToggleItemListStatus() {
        let itemID = testItemList[0].id
        
        ModelController.shared.toggleListStatus(itemID: itemID)
        
        let itemsInList = ModelController.shared.returnAllItemsInList(testListId)
        
        if let firstItem = itemsInList.first {
            XCTAssertTrue(itemID == firstItem.id)
            XCTAssertTrue(firstItem.listed)
        } else {
            XCTFail()
        }
    }
    
    func testToggleItemCompletionStatus() {
        let itemID = testItemList[0].id
        
        ModelController.shared.toggleCompletionStatus(itemID: itemID)
        
        let itemsInList = ModelController.shared.returnAllItemsInList(testListId)
        
        if let firstItem = itemsInList.first {
            XCTAssertTrue(firstItem.id == itemID)
            XCTAssertTrue(firstItem.completed)
        } else {
            XCTFail()
        }
    }
    
    func testDeleteItemInList() {
        let firstItemID = testItemList.first?.id
        
        var updatedList = ModelController.shared.deleteItem(0, in: testItemList)
        updatedList = ModelController.shared.returnAllItemsInList(testListId)
        
        if let firstItem = updatedList.first {
            XCTAssertTrue(firstItemID != nil && firstItemID != firstItem.id)
        } else {
            XCTFail()
        }
    }
    
    func testDeleteList() {
        let sampleLists = ModelController.shared.deleteList(listId: testListId)
        
        guard sampleLists.count > 0 else {
            XCTAssertTrue(sampleLists.count == 0)
            
            return
        }
 
        XCTAssertTrue(sampleLists.count < testLists.count)
    }
    
    func testReorderList() {
        guard testLists.count > 1 else {
            XCTFail("Not enough lists to reorder the array.")
            
            return
        }
        
        let firstListID = testLists[0].id
        let secondListID = testLists[1].id
        
        testLists = ModelController.shared.reorder(lists: testLists, 0, 1)
        
        let savedLists = ModelController.shared.returnAllLists()
        
        XCTAssertTrue(savedLists[0].id == secondListID && savedLists[1].id == firstListID)
    }
    
    func testReorderItemInList() {
        for item in testItemList {
            ModelController.shared.toggleListStatus(itemID: item.id)
        }
        
        var listItems = ModelController.shared.returnFilteredItemsInList(listId: testListId)
        
        guard listItems.count > 1 else {
            XCTFail("Not enough items to test reorder.")
            
            return
        }
        
        listItems = ModelController.shared.reorder(items: listItems, 0, 1)
        
        let updatedListItems = ModelController.shared.returnFilteredItemsInList(listId: testListId)
        
        XCTAssertEqual(listItems, updatedListItems)
    }
    
    func testReturnSortedItemsInList() {
        // List The Items
        for item in testItemList {
            ModelController.shared.toggleListStatus(itemID: item.id)
        }
        
        var itemsSorted = true
        
        let listedItems = ModelController.shared.returnSortedItemsInList(testListId)
        
        for (index, item) in listedItems.enumerated() {
            if item.index! != index || item.listed == false {
                itemsSorted = false
            }
        }
        
        XCTAssertTrue(itemsSorted)
    }
    
    func testPurgeList() {
        let itemID = testItemList[0].id
        
        // Update local array before passing into ModelController
        testItemList[0].listed = true
        testItemList[0].completed = true
        
        // Update the item in Core Data
        ModelController.shared.toggleListStatus(itemID: itemID)
        ModelController.shared.toggleCompletionStatus(itemID: itemID)
        
        _ = ModelController.shared.purgeCompleted(items: testItemList)
        
        let savedListItems = ModelController.shared.returnFilteredItemsInList(listId: testListId)
        
        var allItemsPurged = true
        
        for item in savedListItems {
            if item.completed {
                allItemsPurged = false
            }
        }
        
        XCTAssert(allItemsPurged)
    }

}

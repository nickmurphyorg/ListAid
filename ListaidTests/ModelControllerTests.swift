//
//  ModelControllerTests.swift
//  ModelControllerTests
//
//  Created by Nick Murphy on 9/30/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import XCTest
@testable import Listaid

class ModelControllerTests: XCTestCase {

    var testLists: [List]!
    var testItemList: [Item]!
    
    let testRenameString = "Testing123"
    let testItemName = "TestItem"
    let testItemRename = "TestItemRename"
    
    override func setUp() {
        testLists = ModelController.shared.addNewList()
        testItemList = ModelController.shared.addItemToList(listIndex: testLists.count - 1, itemName: testItemName)
    }

    override func tearDown() {
        _ = ModelController.shared.deleteList(listIndex: testLists.count - 1)
        testLists = nil
        testItemList = nil
    }

    func testAddNewList() {
        let currentListCount = testLists.count
        
        testLists = ModelController.shared.addNewList()

        XCTAssertEqual(testLists.count, currentListCount + 1)
    }
    
    func testUpdateListName() {
        ModelController.shared.updateListName(listIndex: testLists.count - 1, newName: testRenameString)
        
        let savedName = ModelController.shared.returnSavedListName(listIndex: testLists.count - 1)
        
        XCTAssertEqual(savedName, testRenameString)
    }
    
    func testReturnSavedListName() {
        let savedListName = ModelController.shared.returnSavedListName(listIndex: testLists.count - 1)
        
        XCTAssertTrue(savedListName != nil)
    }
    
    func testAddItemToList() {
        let itemsInList = ModelController.shared.addItemToList(listIndex: testLists.count - 1, itemName: testItemName)
        
        if let itemsInList = itemsInList {
            let lastItemInList = itemsInList.last
            
            XCTAssertEqual(testItemName, lastItemInList?.name)
        } else {
            XCTFail("Item was not added to list.")
        }
    }
    
    func testReturnAllItemsInList() {
        let itemsInList = ModelController.shared.returnAllItemsInList(atIndex: testLists.count-1)
        
        XCTAssertTrue(itemsInList != nil)
    }
    
    func testReturnFilteredList() {
        let filteredList = ModelController.shared.returnFilteredList(atIndex: testLists.count - 1)
        
        if let filteredList = filteredList {
            let sansListed = filteredList.items.filter { $0.listed == true }
            
            XCTAssertTrue(sansListed.count == 0)
        } else {
            XCTFail("Filtered list could not be returned.")
        }
    }
    
    func testRenameItemInList() {
        let updatedItemList = ModelController.shared.renameItemInList(listIndex: testLists.count - 1, itemIndex: 0, newName: testItemRename)
        let renamedItem = updatedItemList?.first
        
        if let renamedItem = renamedItem {
            XCTAssertEqual(renamedItem.name, testItemRename)
        } else {
            XCTFail("Renamed item could not be unwrapped.")
        }
    }
    
    func testToggleItemListStatus() {
        let itemID = testItemList[0].id
        
        ModelController.shared.toggleItemListStatus(listIndex: testLists.count - 1, itemID: itemID)
        
        let itemsInList = ModelController.shared.returnAllItemsInList(atIndex: testLists.count - 1)
        
        if let itemsInList = itemsInList {
            XCTAssertTrue(itemsInList[0].listed)
        } else {
            XCTFail("Item could not be checked for list status.")
        }
    }
    
    func testToggleItemCompletionStatus() {
        let itemID = testItemList[0].id
        
        ModelController.shared.toggleItemCompletionStatus(listIndex: testLists.count - 1, itemID: itemID)
        
        let itemsInList = ModelController.shared.returnAllItemsInList(atIndex: testLists.count - 1)
        
        if let itemsInList = itemsInList {
            XCTAssertTrue(itemsInList[0].completed)
        } else {
            XCTFail("Item could not be checked for list status.")
        }
    }
    
    func testDeleteItemInList() {
        let allItemsInList = ModelController.shared.returnAllItemsInList(atIndex: testLists.count - 1)
        let updatedList = ModelController.shared.deleteItemInList(listIndex: testLists.count - 1, itemIndex: 0)
        
        if allItemsInList != nil && updatedList != nil {
            XCTAssertTrue(allItemsInList!.count > updatedList!.count)
        } else {
            XCTFail("Item could not be deleted from list.")
        }
    }
    
    func testDeleteList() {
        let sampleLists = ModelController.shared.deleteList(listIndex: testLists.count-1)
        
        guard sampleLists.count > 0 else {
            XCTAssertTrue(sampleLists.count == 0)
            
            testLists = sampleLists
            
            return
        }

        XCTAssertTrue(sampleLists.count < testLists.count)
        
        testLists = sampleLists
    }

}

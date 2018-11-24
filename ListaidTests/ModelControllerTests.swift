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
    var testList: List!
    
    let testRenameString = "Testing123"
    
    override func setUp() {
        testList = List(name: "Test List 1", items: [])
        
        let itemOne = Item(name: "Item One", listed: true, completed: false)
        let itemTwo = Item(name: "Item Two", listed: true, completed: false)
        
        testList.items.append(itemOne)
        testList.items.append(itemTwo)
        
        testLists = ModelController.shared.returnAllLists()
    }

    override func tearDown() {
        testLists = nil
        testList = nil
    }

    func testAddNewList() {
        // Only listed items will be returned from Model Controller in lists.
        testLists = ModelController.shared.addNewList(newList: testList)
        
        let lastList = testLists.popLast()
        
        if let lastList = lastList {
            XCTAssertEqual(lastList, testList)
        } else {
            XCTFail("Last list could not be unwrapped.")
        }
    }
    
    func testRenameList() {
        ModelController.shared.updateListName(listIndex: testLists.count-1, newName: testRenameString)
        
        let savedName = ModelController.shared.returnSavedListName(listIndex: testLists.count-1)
        
        XCTAssertEqual(savedName, testRenameString)
    }
    
    func testReturnAllItemsInList() {
        let itemsInList = ModelController.shared.returnAllItemsInList(atIndex: testLists.count-1)
        
        XCTAssertEqual(testList.items, itemsInList)
    }
    
    func testFilteredList() {
        let filteredTestList = ModelController.shared.returnFilteredList(atIndex: testLists.count-1)
        
        XCTAssertEqual(filteredTestList, testList)
    }
    
    func testDeleteList() {
        var sampleLists = ModelController.shared.deleteList(listIndex: testLists.count-1)
        
        guard sampleLists.count > 0 else {
            XCTAssertTrue(sampleLists.count == 0)
            
            return
        }
        
        let lastList = sampleLists.popLast()
        
        if let lastList = lastList {
            XCTAssertNotEqual(lastList, testList)
        } else {
            XCTFail("Last list could not be unwrapped.")
        }
    }

}

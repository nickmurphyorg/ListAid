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
    
    override func setUp() {
        testList = List(name: "Test List 1", items: [])
        
        let itemOne = Item(name: "Item One", listed: true, completed: false)
        let itemTwo = Item(name: "Item Two", listed: true, completed: false)
        
        testList.items.append(itemOne)
        testList.items.append(itemTwo)
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

}

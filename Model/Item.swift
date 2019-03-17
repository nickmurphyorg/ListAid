//
//  Item.swift
//  Listaid
//
//  Created by Nick Murphy on 9/30/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import Foundation
import CoreData

struct Item: Equatable {
    var id: NSManagedObjectID
    var index: Int?
    var name: String
    var listed: Bool
    var completed: Bool
}

extension Item {
    init(itemEntity: NSManagedObject) {
        let loadedEntity = itemEntity as! ItemObject
        let entityIndex = Int(loadedEntity.index)
        
        self.id = itemEntity.objectID
        self.index = entityIndex >= 0 ? entityIndex : nil
        self.name = loadedEntity.name ?? ""
        self.listed = loadedEntity.listed
        self.completed = loadedEntity.completed
    }
}

//
//  List.swift
//  Listaid
//
//  Created by Nick Murphy on 9/30/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import Foundation
import CoreData

struct List: Equatable {
    var id: NSManagedObjectID
    var index: Int?
    var name: String
    var items: [Item]
}

extension List {
    init(drinkEntity: NSManagedObject) {
        let loadedEntity = drinkEntity as! ListObject
        let entityIndex = Int(loadedEntity.index)
        
        self.id = loadedEntity.objectID
        self.index = entityIndex >= 0 ? entityIndex : nil
        self.name = loadedEntity.name ?? ""
        self.items = []
        
        if loadedEntity.items != nil {
            for item in loadedEntity.items!.allObjects {
                let savedItem = Item.init(itemEntity: item as! NSManagedObject)
                
                self.items.append(savedItem)
            }
        }
    }
}

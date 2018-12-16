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
    var name: String
    var items: [Item]
}

extension List {
    init(drinkEntity: NSManagedObject) {
        let loadedEntity = drinkEntity as! ListObject
        self.id = loadedEntity.objectID
        self.name = drinkEntity.value(forKey: "name") as? String ?? ""
        self.items = []
        
        if loadedEntity.items != nil {
            for item in loadedEntity.items!.allObjects {
                let savedItem = Item.init(itemEntity: item as! NSManagedObject)
                
                self.items.append(savedItem)
            }
        }
    }
}

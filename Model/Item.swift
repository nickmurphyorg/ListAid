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
        self.id = itemEntity.objectID
        self.index = itemEntity.value(forKey: "index") as? Int ?? nil
        self.name = itemEntity.value(forKey: "name") as? String ?? ""
        self.listed = itemEntity.value(forKey: "listed") as? Bool ?? false
        self.completed = itemEntity.value(forKey: "completed") as? Bool ?? false
    }
}

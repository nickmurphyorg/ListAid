//
//  IndexOfView.swift
//  Listaid
//
//  Created by Nick Murphy on 2/17/19.
//  Copyright © 2019 Nick Murphy. All rights reserved.
//

import UIKit

extension UIView {
    
    func indexOf(_ object: AnyObject) -> Int? {
        var index: Int?
        
        let coordinates = object.convert(CGPoint.zero, to: self)
        
        if self.isMember(of: UITableView.self) {
            let tableView = self as! UITableView
            
            index = tableView.indexPathForRow(at: coordinates)?.row
        } else if self.isMember(of: UICollectionView.self) {
            let collectionView = self as! UICollectionView
            
            index = collectionView.indexPathForItem(at: coordinates)?.item
        }
        
        return index
    }
    
}

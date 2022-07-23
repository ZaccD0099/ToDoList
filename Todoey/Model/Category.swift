//
//  Category.swift
//  Todoey
//
//  Created by Zach Davis on 7/22/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var title : String?
    @objc dynamic var hexColor : String = ""
    let items = List<Item>()
    
}

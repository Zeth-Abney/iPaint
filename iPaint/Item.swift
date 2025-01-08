//
//  Item.swift
//  iPaint
//
//  Created by Zeth Abney on 1/7/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var title: String
    
    init(timestamp: Date, title: String = "") {
        self.timestamp = timestamp
        self.title = title
    }
}

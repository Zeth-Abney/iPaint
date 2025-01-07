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
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

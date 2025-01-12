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
    let timestamp: Date       // Creation timestamp
    let itemIndex: Int        // Unique forever-index
    var lastEdited: Date      // Last edit timestamp
    var title: String
    var details: String?
    var canvasData: Data?
    
    init(timestamp: Date = Date(), itemIndex: Int, title: String = "", details: String? = nil, canvasData: Data? = nil) {
        self.timestamp = timestamp
        self.itemIndex = itemIndex
        self.lastEdited = timestamp
        self.title = title
        self.details = details
        self.canvasData = canvasData
    }
}

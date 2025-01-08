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
    let timestamp: Date
    var title: String
    var details: String?
    
    init(timestamp: Date = Date(), title: String = "", details: String? = nil) {
        self.timestamp = timestamp
        self.title = title
        self.details = details
    }
}

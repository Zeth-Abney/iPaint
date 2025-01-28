//
//  AppMetaData.swift
//  iPaint
//
//  Created by Zeth Abney on 1/10/25.
//

import SwiftData
import Foundation

@Model
final class AppMetadata {
    static var lastUsedIndex: Int = 0
    var itemIndex: Int
    
    init() {
        AppMetadata.lastUsedIndex += 1
        self.itemIndex = AppMetadata.lastUsedIndex
    }
}

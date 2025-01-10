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
    var lastUsedIndex: Int
    
    init(lastUsedIndex: Int = -1) {
        self.lastUsedIndex = lastUsedIndex
    }
}

//
//  Item.swift
//  AnglerDiary
//
//  Created by Tway IT on 7/31/24.
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

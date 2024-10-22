//
//  Item.swift
//  mealFinder
//
//  Created by 杨舒捷 on 10/22/24.
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

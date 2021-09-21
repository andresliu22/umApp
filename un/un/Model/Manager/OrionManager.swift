//
//  OrionManager.swift
//  un
//
//  Created by Andres Liu on 1/21/21.
//

import Foundation

class OrionManager {
    static let shared = OrionManager()
    var orionVC = AccountStateOrionVC()
}

class OrionFilterManager {
    static let shared = OrionFilterManager()
    var orionFiltersVC = OrionFilterVC()
}

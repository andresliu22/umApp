//
//  InversionManager.swift
//  un
//
//  Created by Andres Liu on 1/18/21.
//

import Foundation

class InversionManager {
    static let shared = InversionManager()
    var inversionVC = InversionVC()
}

class InversionFilterManager {
    static let shared = InversionFilterManager()
    var inversionFiltersVC = InversionFiltersVC()
}
